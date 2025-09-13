from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import PartViewSet, VendorViewSet, InspectionViewSet

# Create router and register viewsets
router = DefaultRouter()
router.register(r'parts', PartViewSet)
router.register(r'vendors', VendorViewSet)
router.register(r'inspections', InspectionViewSet)

urlpatterns = [
    path('', include(router.urls)),
]

# This creates the following endpoints:
# GET/POST    /api/parts/
# GET/PUT/DELETE /api/parts/{id}/
# GET         /api/parts/{id}/inspections/
# GET/POST    /api/vendors/
# GET/PUT/DELETE /api/vendors/{id}/
# GET/POST    /api/inspections/
# GET/PUT/DELETE /api/inspections/{id}/