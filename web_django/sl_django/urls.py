from django.urls import path
from . import views

urlpatterns = [
    path('', views.sl_django, name='sl_django'),
]