from django.views.decorators.csrf import csrf_exempt
from django.contrib.auth import authenticate
from django.contrib.auth import login as login_django
from .models import UserProfile, FichaDeTreino
from django.contrib.auth.models import User
from django.http import JsonResponse
import json
import google.generativeai as genai

genai.configure(api_key="AIzaSyD0IG3ad1xGW5UCwvON-fWiD1jTt7a8uwE")
model = genai.GenerativeModel("gemini-1.5-flash")

@csrf_exempt
def cadastro(request):
    if request.method == 'POST':
        try:
            data = json.loads(request.body)
            email = data.get('email')
            usuario = data.get('usuario')
            senha = data.get('senha')
            idade = data.get('idade')
            peso = data.get('peso')
            metas = data.get('metas', '')
            frequencia = data.get('frequencia', '')
            descanso = data.get('descanso', [])

            descanso_formated = [i + ',' for i in descanso]

            print(descanso_formated)

            response = model.generate_content(f'Gere uma ficha de treino formatada e apresentável, mas como texto corrido, como se fosse pra um pdf, sem <br> e coisa do tipo. Todos os dias devem estar escritos na ficha, incluindo os de descanso, ou seja, se a frequencia é 5 dias, ainda assim devem ter 7 dias na ficha, sendo indicados os que são somente descanso. O nome do programa deve ser curto, com no máximo 10 palavras, e inspirador. Inclua o objetivo do aluno de forma clara. Informe a frequência de treinos por semana e liste os dias de descanso no formato: "dia-de-descanso, dia-de-descanso, ...". Organize os treinos por dia da semana, indicando o nome do dia, os grupos musculares (até 2-3 por sessão) e o treino, que deve conter pelo menos 6 exercícios. Cada exercício deve incluir o nome do exercício, o número de séries, a faixa de repetições (ex.: "8-12") e o descanso em segundos. Finalize com um campo de observações contendo um breve texto de no máximo 30 palavras, com orientações relacionadas ao objetivo do treino e às informações fornecidas. Utilize as seguintes informações: objetivo: {metas}, frequência: {frequencia} vezes por semana, dias de descanso: {descanso_formated}. Certifique-se de que o conteúdo esteja bem estruturado e visualmente interessante.')
            ficha_de_treino = response.text


            if not all([email, usuario, senha, idade, peso]):
                return JsonResponse({'message': 'Campos obrigatórios faltando!', 'status': 'error'}, status=400)

            if not isinstance(descanso, list):
                return JsonResponse({'message': 'O campo "descanso" deve ser uma lista!', 'status': 'error'}, status=400)

            new_user = User.objects.create_user(username=usuario, email=email, password=senha)
            new_user.save()


            UserProfile.objects.create(
                usuario=new_user,
                idade=idade,
                peso=peso,
                metas=metas,
                frequencia=frequencia,
                descanso={"dias": descanso}
            )

            ficha = FichaDeTreino.objects.create(
                usuario=new_user,
                exercicios = ficha_de_treino
            )

            ficha.save()

            return JsonResponse({'message': 'Cadastro realizado com sucesso!', 'status': 'success'}, status=201)
        except json.JSONDecodeError:
            return JsonResponse({'message': 'Erro ao processar os dados JSON!', 'status': 'error'}, status=400)
        except Exception as e:
            return JsonResponse({'message': f'Erro inesperado: {str(e)}', 'status': 'error'}, status=500)
    else:
        return JsonResponse({'message': 'Método não permitido', 'status': 'error'}, status=405)

@csrf_exempt
def login(request):
    if request.method == 'POST':
        try:
            data = json.loads(request.body)
            usuario = data.get('usuario')
            senha = data.get('senha')

            print(usuario)
            print(senha)

            user = authenticate(username=usuario, password=senha)

            if user:
                login_django(request, user)
                return JsonResponse({'message': 'Autenticado!', 'status': 'success'}, status=200)
            else:
                return JsonResponse({'message': 'Usuário ou senha incorretos!', 'status': 'error'}, status=400)
        except json.JSONDecodeError:
            return JsonResponse({'message': 'Erro ao processar os dados JSON!', 'status': 'error'}, status=400)
    else:
        return JsonResponse({'message': 'Método não permitido', 'status': 'error'}, status=405)
    
def fichaDeTreino(request, usuario):
    if request.method == 'GET':
        try:
            user = User.objects.get(username=usuario)
            ficha = FichaDeTreino.objects.get(usuario=user)
            if not ficha:
                return JsonResponse({'message': 'Nenhuma ficha de treino encontrada para este usuário.', 'status': 'error'}, status=404)

            return JsonResponse({
                'message': 'Ficha de treino encontrada!',
                'status': 'success',
                'ficha': {
                    'usuario': usuario,
                    'exercicios': ficha.exercicios
                }
            }, status=200)

        except Exception as e:
            return JsonResponse({'message': f'Erro ao buscar ficha de treino: {str(e)}', 'status': 'error'}, status=500)
    else:
        return JsonResponse({'message': 'Método não permitido', 'status': 'error'}, status=405)