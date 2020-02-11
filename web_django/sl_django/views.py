from django.shortcuts import render

# Create your views here.

def sl_django(request):
	return render(request, 'sl_django.html', {})

