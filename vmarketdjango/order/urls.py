from django.urls import path

from order import views

urlpatterns = [
    path('cart/', views.cart, name='cart'),
    path('checkout/', views.checkout),
    path('orders/', views.OrdersList.as_view()),
]