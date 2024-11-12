from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import APIView
from .serializers import UserSerializer
from django.db import IntegrityError

class RegisterUser(APIView):
    """
    API endpoint for registering a new user.
    """
    def post(self, request):
        serializer = UserSerializer(data=request.data)
        
        # Validate and create the user
        if serializer.is_valid():
            try:
                serializer.save()
                return Response({"message": "User registered successfully!", "data": serializer.data}, status=status.HTTP_201_CREATED)
            except IntegrityError as e:
                # Handle unique constraint violations (e.g., duplicate username or email)
                return Response({"error": "User with this username or email already exists."}, status=status.HTTP_400_BAD_REQUEST)
            except Exception as e:
                # Handle any other exceptions
                return Response({"error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
        
        # If data is invalid, return detailed validation errors
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)