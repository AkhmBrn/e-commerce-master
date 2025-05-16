from django.urls import path

from order import views

urlpatterns = [
    path('cart/', views.CartView.as_view()),
    path('checkout/', views.checkout),
    path('orders/', views.OrdersList.as_view()),
]