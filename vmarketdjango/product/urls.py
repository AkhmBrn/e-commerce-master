from django.urls import path, include

from product import views

urlpatterns = [
    path('latest-products/', views.LatestProductsList.as_view()),
    path('products/', views.ProductList.as_view()),  # New endpoint for all products
    path('products/<int:pk>/', views.ProductDetailById.as_view()),  # New endpoint for product by ID
    path('categories/', views.CategoryList.as_view()),
    path('products/search/', views.search),
    path('products/<slug:category_slug>/<slug:product_slug>/', views.ProductDetail.as_view()),
    path('products/<slug:category_slug>/', views.CategoryDetail.as_view()),
]
