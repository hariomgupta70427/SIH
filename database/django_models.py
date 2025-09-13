# Django ORM Models for Inventory System
import uuid
from django.db import models
from django.core.validators import MinValueValidator, MaxValueValidator

class Vendor(models.Model):
    """Vendor model for suppliers"""
    STATUS_CHOICES = [
        ('active', 'Active'),
        ('inactive', 'Inactive'),
    ]
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    name = models.CharField(max_length=255)
    contact_info = models.JSONField(default=dict, blank=True)  # Flexible contact storage
    status = models.CharField(max_length=10, choices=STATUS_CHOICES, default='active')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'vendors'
        indexes = [
            models.Index(fields=['status']),
        ]
    
    def __str__(self):
        return self.name

class Part(models.Model):
    """Part model for inventory items"""
    STATUS_CHOICES = [
        ('active', 'Active'),
        ('inactive', 'Inactive'),
        ('maintenance', 'Maintenance'),
    ]
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    qr_code = models.CharField(max_length=255, unique=True)  # QR identifier
    name = models.CharField(max_length=255)
    part_number = models.CharField(max_length=100, unique=True)
    description = models.TextField(blank=True)
    status = models.CharField(max_length=15, choices=STATUS_CHOICES, default='active')
    quantity = models.IntegerField(default=0, validators=[MinValueValidator(0)])
    unit_price = models.DecimalField(
        max_digits=10, 
        decimal_places=2, 
        null=True, 
        blank=True,
        validators=[MinValueValidator(0)]
    )
    vendor = models.ForeignKey(Vendor, on_delete=models.CASCADE, related_name='parts')
    location = models.CharField(max_length=255, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'parts'
        indexes = [
            models.Index(fields=['qr_code']),
            models.Index(fields=['part_number']),
            models.Index(fields=['vendor']),
            models.Index(fields=['status']),
        ]
    
    def __str__(self):
        return f"{self.name} ({self.part_number})"

class Inspection(models.Model):
    """Inspection model for quality control"""
    RESULT_CHOICES = [
        ('passed', 'Passed'),
        ('failed', 'Failed'),
        ('pending', 'Pending'),
    ]
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    part = models.ForeignKey(Part, on_delete=models.CASCADE, related_name='inspections')
    inspector_name = models.CharField(max_length=255)
    inspection_date = models.DateTimeField(auto_now_add=True)
    result = models.CharField(max_length=10, choices=RESULT_CHOICES)
    score = models.IntegerField(
        null=True, 
        blank=True,
        validators=[MinValueValidator(0), MaxValueValidator(100)]
    )
    remarks = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        db_table = 'inspections'
        indexes = [
            models.Index(fields=['part']),
            models.Index(fields=['inspection_date']),
            models.Index(fields=['result']),
        ]
    
    def __str__(self):
        return f"Inspection of {self.part.name} by {self.inspector_name}"