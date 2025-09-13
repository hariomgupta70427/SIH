from rest_framework import serializers
from .models import Part, Vendor, Inspection

class VendorSerializer(serializers.ModelSerializer):
    """Serializer for Vendor model"""
    parts_count = serializers.SerializerMethodField()
    
    class Meta:
        model = Vendor
        fields = ['id', 'name', 'email', 'phone', 'address', 'status', 
                 'created_at', 'updated_at', 'parts_count']
        read_only_fields = ['id', 'created_at', 'updated_at']
    
    def get_parts_count(self, obj):
        return obj.parts.count()

class PartSerializer(serializers.ModelSerializer):
    """Serializer for Part model"""
    vendor_name = serializers.CharField(source='vendor.name', read_only=True)
    inspections_count = serializers.SerializerMethodField()
    
    class Meta:
        model = Part
        fields = ['id', 'name', 'part_number', 'description', 'status', 
                 'quantity', 'price', 'vendor', 'vendor_name', 
                 'created_at', 'updated_at', 'inspections_count']
        read_only_fields = ['id', 'created_at', 'updated_at']
    
    def get_inspections_count(self, obj):
        return obj.inspections.count()

class InspectionSerializer(serializers.ModelSerializer):
    """Serializer for Inspection model"""
    part_name = serializers.CharField(source='part.name', read_only=True)
    part_number = serializers.CharField(source='part.part_number', read_only=True)
    
    class Meta:
        model = Inspection
        fields = ['id', 'part', 'part_name', 'part_number', 'inspector_name', 
                 'inspection_date', 'status', 'notes', 'score', 
                 'created_at', 'updated_at']
        read_only_fields = ['id', 'inspection_date', 'created_at', 'updated_at']
    
    def validate_score(self, value):
        if value is not None and (value < 0 or value > 100):
            raise serializers.ValidationError("Score must be between 0 and 100")
        return value