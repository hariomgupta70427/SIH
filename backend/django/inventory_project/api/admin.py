from django.contrib import admin
from .models import Part, Vendor, Inspection

@admin.register(Vendor)
class VendorAdmin(admin.ModelAdmin):
    list_display = ['name', 'email', 'status', 'created_at']
    list_filter = ['status', 'created_at']
    search_fields = ['name', 'email']

@admin.register(Part)
class PartAdmin(admin.ModelAdmin):
    list_display = ['name', 'part_number', 'vendor', 'status', 'quantity', 'price']
    list_filter = ['status', 'vendor', 'created_at']
    search_fields = ['name', 'part_number', 'description']

@admin.register(Inspection)
class InspectionAdmin(admin.ModelAdmin):
    list_display = ['part', 'inspector_name', 'status', 'score', 'inspection_date']
    list_filter = ['status', 'inspection_date']
    search_fields = ['part__name', 'inspector_name']