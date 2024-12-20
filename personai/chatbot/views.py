from google import generativeai as genai
from django.shortcuts import render, reverse
from django.contrib.auth.decorators import login_required
from .models import ChatBot
from django.http import HttpResponseRedirect, JsonResponse

# Adicionei minha chave de API aqui - Felipe Costa
genai.configure(api_key="AIzaSyCJMtWNLvxFkD7rwW1Tr2OIi-TFEwtj74I")

# @login_required
def chatbot(request):
    if request.method == "POST":
        texto = request.POST.get("text")
        modelo = genai.GenerativeModel("gemini-pro")
        chat = modelo.start_chat()
        resposta = chat.send_message(texto)
        user = request.user
        ChatBot.objects.create(text_input=texto, gemini_output=resposta.texto, user=user)
        # Extrai dados pelo resposta
        resposta_data = {
            "text": resposta.texto,  # Assumindo que o resposta.text contêm os dados de resposta relevantes
            # Adicionar mais dados importantes aqui se necessário
        }
        return JsonResponse({"data": resposta_data})
    else:
        return HttpResponseRedirect(
            reverse("chat")
        )  # Redirecionar a pagina do chat para GET requests

# @login_required
def chat(request):
    user = request.user
    chats = ChatBot.objects.filter(user=user)
    return render(request, "chat_bot.html", {"chats": chats})
