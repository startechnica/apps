from django.utils.text import slugify

from dcim.choices import DeviceStatusChoices, SiteStatusChoices
from dcim.models import Device, DeviceRole, DeviceType, Manufacturer, Site
from extras.scripts import *


class NewBranchScript(Script):

    class Meta:
        name = "New Branch"
        description = "Provision a new branch site"
        field_order = ['site_name', 'switch_count', 'switch_model']

    site_name = StringVar(
        description="Name of the new site"
    )
    switch_count = IntegerVar(
        description="Number of access switches to create"
    )
    manufacturer = ObjectVar(
        model=Manufacturer,
        required=False
    )
    switch_model = ObjectVar(
        description="Access switch model",
        model=DeviceType,
        query_params={
            'manufacturer_id': '$manufacturer'
        }
    )

    def run(self, data, commit):

        # Create the new site
        site = Site(
            name=data['site_name'],
            slug=slugify(data['site_name']),
            status=SiteStatusChoices.STATUS_PLANNED
        )
        site.full_clean()
        site.save()
        self.log_success(f"Created new site: {site}")

        # Create access switches
        switch_role = DeviceRole.objects.get(name='Access Switch')
        for i in range(1, data['switch_count'] + 1):
            switch = Device(
                device_type=data['switch_model'],
                name=f'{site.slug}-switch{i}',
                site=site,
                status=DeviceStatusChoices.STATUS_PLANNED,
                device_role=switch_role
            )
            switch.full_clean()
            switch.save()
            self.log_success(f"Created new switch: {switch}")

        # Generate a CSV table of new devices
        output = [
            'name,make,model'
        ]
        for switch in Device.objects.filter(site=site):
            attrs = [
                switch.name,
                switch.device_type.manufacturer.name,
                switch.device_type.model
            ]
            output.append(','.join(attrs))

        return '\n'.join(output)