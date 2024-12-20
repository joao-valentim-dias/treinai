from django.db import models
from django.contrib.auth.models import User
from core.models import UserProfile

# Create your models here.

class ChatBot(models.Model):
    user = models.ForeignKey(
        UserProfile, on_delete=models.CASCADE, related_name="GeminiUser", null=True
    )
    texto_input = models.CharField(max_length=500)
    gemini_output = models.JSONField()
    data = models.DateTimeField(auto_now_add=True, blank=True, null=True)
    def __str__(self):
        return self.texto_input


class Treinos(models.Model):
    user = models.ForeignKey(UserProfile, on_delete=models.CASCADE, related_name="Treinos")
    treinos_data = models.JSONField()
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)



def texto(self):
    return  f"Treino de {self.user.username} - {self.created_at.date()}"

