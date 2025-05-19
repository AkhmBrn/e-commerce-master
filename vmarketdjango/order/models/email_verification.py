from django.contrib.auth.models import User
from django.db import models
from django.utils import timezone
from datetime import timedelta

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
