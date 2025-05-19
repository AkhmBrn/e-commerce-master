from django.contrib.auth.models import User
from django.contrib.auth import authenticate
from rest_framework import status
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.authentication import TokenAuthentication
from rest_framework.permissions import IsAuthenticated
from rest_framework.authtoken.models import Token

class AccountDeletionView(APIView):
    authentication_classes = [TokenAuthentication]
    permission_classes = [IsAuthenticated]
    
    def post(self, request, format=None):
        """Delete the user's account after password confirmation"""
        password = request.data.get('password')
        if not password:
            return Response(
                {'error': 'Password is required for account deletion'}, 
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Verify password
        user = authenticate(username=request.user.username, password=password)
        if not user:
            return Response(
                {'error': 'Invalid password'}, 
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Delete the auth token
        Token.objects.filter(user=request.user).delete()
        
        # Delete the user account
        username = request.user.username
        request.user.delete()
        
        return Response(
            {'success': f'Account {username} has been deleted'},
            status=status.HTTP_200_OK
        )
