from django.contrib import admin
from order.models import Order, OrderItem, Address, UserSettings, UserProfile, EmailVerification

admin.site.register(Order)
admin.site.register(OrderItem)
admin.site.register(Address)
admin.site.register(UserSettings)
admin.site.register(UserProfile)
admin.site.register(EmailVerification)