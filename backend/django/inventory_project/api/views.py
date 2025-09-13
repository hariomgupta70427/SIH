from rest_framework import viewsets, status
from rest_framework.response import Response
from rest_framework.decorators import action
from django_filters.rest_framework import DjangoFilterBackend
from django.db.models import Q
from .models import Part, Vendor, Inspection
from .serializers import PartSerializer, VendorSerializer, InspectionSerializer

class VendorViewSet(viewsets.ModelViewSet):
    """
    ViewSet for Vendor CRUD operations
    Provides: GET /api/vendors/, POST /api/vendors/, 
             GET /api/vendors/{id}/, PUT /api/vendors/{id}/, DELETE /api/vendors/{id}/
    """
    queryset = Vendor.objects.all().order_by('-created_at')
    serializer_class = VendorSerializer
    filter_backends = [DjangoFilterBackend]
    filterset_fields = ['status']
    
    def get_queryset(self):
        queryset = super().get_queryset()
        search = self.request.query_params.get('search')
        if search:
            queryset = queryset.filter(
                Q(name__icontains=search) | Q(email__icontains=search)
            )
        return queryset

class PartViewSet(viewsets.ModelViewSet):
    """
    ViewSet for Part CRUD operations
    Provides: GET /api/parts/, POST /api/parts/, 
             GET /api/parts/{id}/, PUT /api/parts/{id}/, DELETE /api/parts/{id}/
    """
    queryset = Part.objects.select_related('vendor').all().order_by('-created_at')
    serializer_class = PartSerializer
    filter_backends = [DjangoFilterBackend]
    filterset_fields = ['status', 'vendor']
    
    def get_queryset(self):
        queryset = super().get_queryset()
        search = self.request.query_params.get('search')
        if search:
            queryset = queryset.filter(
                Q(name__icontains=search) | 
                Q(part_number__icontains=search) |
                Q(description__icontains=search)
            )
        return queryset
    
    @action(detail=True, methods=['get'])
    def inspections(self, request, pk=None):
        """Get all inspections for a specific part"""
        part = self.get_object()
        inspections = part.inspections.all().order_by('-inspection_date')
        serializer = InspectionSerializer(inspections, many=True)
        return Response(serializer.data)

class InspectionViewSet(viewsets.ModelViewSet):
    """
    ViewSet for Inspection CRUD operations
    Provides: GET /api/inspections/, POST /api/inspections/, 
             GET /api/inspections/{id}/, PUT /api/inspections/{id}/, DELETE /api/inspections/{id}/
    """
    queryset = Inspection.objects.select_related('part').all().order_by('-inspection_date')
    serializer_class = InspectionSerializer
    filter_backends = [DjangoFilterBackend]
    filterset_fields = ['status', 'part']
    
    def get_queryset(self):
        queryset = super().get_queryset()
        inspector = self.request.query_params.get('inspector')
        if inspector:
            queryset = queryset.filter(inspector_name__icontains=inspector)
        return queryset