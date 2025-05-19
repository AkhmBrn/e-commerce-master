from django.contrib.auth.models import User
from django.db import models
from django.db.models.signals import post_save
from django.dispatch import receiver
from django.utils import timezone
from datetime import timedelta

from product.models import Product

class Order(models.Model):
    user = models.ForeignKey(User, related_name='orders', on_delete=models.CASCADE)
    first_name = models.CharField(max_length=100)
    last_name = models.CharField(max_length=100)
    email = models.CharField(max_length=100)
    address = models.CharField(max_length=100)
    zipcode = models.CharField(max_length=100)
    place = models.CharField(max_length=100)
    phone = models.CharField(max_length=100)
    created_at = models.DateTimeField(auto_now_add=True)
    paid_amount = models.DecimalField(max_digits=9, decimal_places=2, blank=True, null=True)
    stripe_token = models.CharField(max_length=100)
    status = models.CharField(max_length=20, default='pending', 
                            choices=[
                                ('pending', 'Pending'),
                                ('processing', 'Processing'),
                                ('shipped', 'Shipped'),
                                ('delivered', 'Delivered'),
                                ('cancelled', 'Cancelled'),
                            ])

    class Meta:
        ordering = ['-created_at',]

    def __str__(self):
        return self.first_name

class OrderItem(models.Model):
    order = models.ForeignKey(Order, related_name='items', on_delete=models.CASCADE)
    product = models.ForeignKey(Product, related_name='items', on_delete=models.CASCADE)
    price = models.DecimalField(max_digits=9, decimal_places=2)
    quantity = models.IntegerField(default=1)

    def __str__(self):
        return '%s' %self.id

class Address(models.Model):
    user = models.ForeignKey(User, related_name='addresses', on_delete=models.CASCADE)
    name = models.CharField(max_length=255)
    address_line1 = models.CharField(max_length=255)
    address_line2 = models.CharField(max_length=255, blank=True, null=True)
    city = models.CharField(max_length=100)
    state = models.CharField(max_length=100)
    zip_code = models.CharField(max_length=20)
    phone = models.CharField(max_length=30)
    is_default = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-is_default', '-updated_at']
        verbose_name_plural = 'Addresses'

    def __str__(self):
        return f"{self.name} - {self.city}, {self.state}"
    
    def save(self, *args, **kwargs):
        # If this address is being set as default, unset default on other addresses
        if self.is_default:
            Address.objects.filter(user=self.user, is_default=True).update(is_default=False)
        
        # If this is the first address for the user, set it as default
        if not self.pk and not Address.objects.filter(user=self.user).exists():
            self.is_default = True
            
        super().save(*args, **kwargs)

class UserSettings(models.Model):
    user = models.OneToOneField(User, related_name='settings', on_delete=models.CASCADE)
    language = models.CharField(max_length=10, default='en')
    currency = models.CharField(max_length=10, default='USD')
    dark_mode = models.BooleanField(default=False)
    email_notifications = models.BooleanField(default=True)
    order_updates = models.BooleanField(default=True)
    promotional_emails = models.BooleanField(default=True)
    newsletter = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name_plural = 'User Settings'

    def __str__(self):
        return f"Settings for {self.user.username}"

# Additional Models for User Profile and Email Verification

class UserProfile(models.Model):
    user = models.OneToOneField(User, related_name='profile', on_delete=models.CASCADE)
    phone = models.CharField(max_length=30, blank=True, null=True)
    date_of_birth = models.DateField(blank=True, null=True)
    profile_picture = models.ImageField(upload_to='profile_pictures/', blank=True, null=True)
    email_verified = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"Profile for {self.user.username}"

class EmailVerification(models.Model):
    user = models.OneToOneField(User, related_name='email_verification', on_delete=models.CASCADE)
    token = models.CharField(max_length=128)
    created_at = models.DateTimeField(auto_now_add=True)
    expires_at = models.DateTimeField(null=True, blank=True)
    
    def save(self, *args, **kwargs):
        # Token expires after 24 hours
        if not self.expires_at:
            self.expires_at = timezone.now() + timedelta(hours=24)
        super().save(*args, **kwargs)
    
    def is_expired(self):
        """Check if the verification token has expired"""
        return timezone.now() > self.expires_at
    
    def __str__(self):
        return f"Email verification for {self.user.email}"

# Signal handlers for UserProfile creation

@receiver(post_save, sender=User)
def create_user_profile(sender, instance, created, **kwargs):
    """Create a UserProfile instance when a new User is created"""
    if created:
        UserProfile.objects.create(user=instance)

@receiver(post_save, sender=User)
def save_user_profile(sender, instance, **kwargs):
    """Save the UserProfile when the User is saved"""
    if hasattr(instance, 'profile'):
        instance.profile.save()
    else:
        # Create profile if it doesn't exist
        UserProfile.objects.create(user=instance)


