from django.urls import path

from order import views
from order import account_views
from order.account_deletion import AccountDeletionView

urlpatterns = [
    # Cart and orders
    path('cart/', views.CartView.as_view()),
    path('checkout/', views.checkout),
    path('orders/', views.OrdersList.as_view()),
    path('orders/<int:pk>/', account_views.OrderDetailView.as_view()),
    
    # User profile and settings
    path('users/me/', account_views.UserProfileView.as_view()),
    path('users/set_password/', account_views.ChangePasswordView.as_view()),
    path('users/settings/', account_views.UserSettingsView.as_view()),
    path('users/delete/', AccountDeletionView.as_view()),
    
    # Email verification
    path('email/verify/', account_views.EmailVerificationView.as_view()),
    path('email/verify/<str:token>/', account_views.EmailVerificationView.as_view()),
    
    # Addresses
    path('addresses/', account_views.AddressViewSet.as_view()),
    path('addresses/<int:pk>/', account_views.AddressDetailView.as_view()),
    path('addresses/<int:pk>/set_default/', account_views.SetDefaultAddressView.as_view()),
]