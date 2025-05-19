from django.contrib.auth.models import User
from django.contrib.auth.password_validation import validate_password
from django.core.exceptions import ValidationError
from django.http import Http404
from django.db import transaction
from django.shortcuts import get_object_or_404
from django.core.mail import send_mail
from django.conf import settings
from django.utils.crypto import get_random_string

from rest_framework import status, authentication, permissions
from rest_framework.decorators import api_view, authentication_classes, permission_classes
from rest_framework.views import APIView
from rest_framework.response import Response

from .models import Address, UserSettings, Order, EmailVerification, UserProfile
from .serializers import (
    AddressSerializer, 
    UserSettingsSerializer, 
    UserSerializer,
    UserProfileSerializer,
    MyOrderSerializer
)

class UserProfileView(APIView):
    authentication_classes = [authentication.TokenAuthentication]
    permission_classes = [permissions.IsAuthenticated]
    
    def get(self, request, format=None):
        """Get the current user's profile"""
        serializer = UserProfileSerializer(request.user)
        return Response(serializer.data)
    
    def patch(self, request, format=None):
        """Update the current user's profile"""
        serializer = UserProfileSerializer(request.user, data=request.data, partial=True)
        if serializer.is_valid():
            # Custom handling for name field to split into first_name and last_name
            if 'name' in request.data:
                name_parts = request.data['name'].split(' ', 1)
                request.user.first_name = name_parts[0]
                if len(name_parts) > 1:
                    request.user.last_name = name_parts[1]
                else:
                    request.user.last_name = ''
                request.user.save()
            
            # Handle additional profile fields if present
            if hasattr(request.user, 'profile'):
                if 'phone' in request.data:
                    request.user.profile.phone = request.data.get('phone', '')
                    request.user.profile.save()
            
            return Response(UserProfileSerializer(request.user).data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class ChangePasswordView(APIView):
    authentication_classes = [authentication.TokenAuthentication]
    permission_classes = [permissions.IsAuthenticated]
    
    def post(self, request, format=None):
        """Change the user's password"""
        current_password = request.data.get('current_password')
        new_password = request.data.get('new_password')
        
        if not current_password or not new_password:
            return Response(
                {'error': 'Both current and new password are required'}, 
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Check current password
        if not request.user.check_password(current_password):
            return Response(
                {'current_password': 'Current password is incorrect'}, 
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Validate and set new password
        try:
            validate_password(new_password, request.user)
            request.user.set_password(new_password)
            request.user.save()
            return Response({'success': 'Password changed successfully'})
        except ValidationError as e:
            return Response({'new_password': list(e)}, status=status.HTTP_400_BAD_REQUEST)

class AddressViewSet(APIView):
    authentication_classes = [authentication.TokenAuthentication]
    permission_classes = [permissions.IsAuthenticated]
    
    def get(self, request, format=None):
        """Get all addresses for the current user"""
        addresses = Address.objects.filter(user=request.user)
        serializer = AddressSerializer(addresses, many=True)
        return Response(serializer.data)
    
    def post(self, request, format=None):
        """Create a new address for the current user"""
        serializer = AddressSerializer(data=request.data, context={'request': request})
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class AddressDetailView(APIView):
    authentication_classes = [authentication.TokenAuthentication]
    permission_classes = [permissions.IsAuthenticated]
    
    def get_object(self, pk):
        try:
            return Address.objects.get(pk=pk, user=self.request.user)
        except Address.DoesNotExist:
            raise Http404
    
    def get(self, request, pk, format=None):
        """Get a specific address"""
        address = self.get_object(pk)
        serializer = AddressSerializer(address)
        return Response(serializer.data)
    
    def put(self, request, pk, format=None):
        """Update an address"""
        address = self.get_object(pk)
        serializer = AddressSerializer(address, data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    def delete(self, request, pk, format=None):
        """Delete an address"""
        address = self.get_object(pk)
        address.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)

class SetDefaultAddressView(APIView):
    authentication_classes = [authentication.TokenAuthentication]
    permission_classes = [permissions.IsAuthenticated]
    
    def post(self, request, pk, format=None):
        """Set an address as the default"""
        try:
            address = Address.objects.get(pk=pk, user=request.user)
            with transaction.atomic():
                # First, unset default on all user addresses
                Address.objects.filter(user=request.user).update(is_default=False)
                # Then, set this one as default
                address.is_default = True
                address.save()
            
            return Response({'success': 'Address set as default'})
        except Address.DoesNotExist:
            raise Http404

class UserSettingsView(APIView):
    authentication_classes = [authentication.TokenAuthentication]
    permission_classes = [permissions.IsAuthenticated]
    
    def get(self, request, format=None):
        """Get user settings"""
        settings, created = UserSettings.objects.get_or_create(user=request.user)
        serializer = UserSettingsSerializer(settings)
        return Response(serializer.data)
    
    def patch(self, request, format=None):
        """Update user settings"""
        settings, created = UserSettings.objects.get_or_create(user=request.user)
        serializer = UserSettingsSerializer(settings, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class EmailVerificationView(APIView):
    """Handle email verification requests and confirmation"""
    
    def post(self, request, format=None):
        """Send verification email to user"""
        email = request.data.get('email')
        if not email:
            return Response(
                {'error': 'Email is required'}, 
                status=status.HTTP_400_BAD_REQUEST
            )
        
        try:
            user = User.objects.get(email=email)
        except User.DoesNotExist:
            return Response(
                {'error': 'No user found with this email address'}, 
                status=status.HTTP_404_NOT_FOUND
            )
        
        # Generate verification token
        token = get_random_string(64)
        
        # Save verification request
        verification, created = EmailVerification.objects.update_or_create(
            user=user,
            defaults={'token': token}
        )
        
        # Send verification email
        verification_url = f"{settings.FRONTEND_URL}/verify-email/{token}"
        send_mail(
            'Email Verification for VMarket',
            f'Please click on the link below to verify your email address:\n\n{verification_url}',
            settings.DEFAULT_FROM_EMAIL,
            [email],
            fail_silently=False,
        )
        
        return Response({'success': 'Verification email sent'})
    
    def get(self, request, format=None):
        """Verify email with token"""
        token = request.query_params.get('token')
        if not token:
            return Response(
                {'error': 'Verification token is required'}, 
                status=status.HTTP_400_BAD_REQUEST
            )
        
        try:
            verification = EmailVerification.objects.get(token=token)
            user = verification.user
            
            # Mark user as verified
            user.profile.email_verified = True
            user.profile.save()
            
            # Delete the verification token
            verification.delete()
            
            return Response({'success': 'Email verified successfully'})
        except EmailVerification.DoesNotExist:
            return Response(
                {'error': 'Invalid or expired verification token'}, 
                status=status.HTTP_400_BAD_REQUEST
            )

class OrderDetailView(APIView):
    authentication_classes = [authentication.TokenAuthentication]
    permission_classes = [permissions.IsAuthenticated]
    
    def get_object(self, pk):
        try:
            return Order.objects.get(pk=pk, user=self.request.user)
        except Order.DoesNotExist:
            raise Http404
    
    def get(self, request, pk, format=None):
        """Get a specific order with details"""
        order = self.get_object(pk)
        serializer = MyOrderSerializer(order)
        return Response(serializer.data)
