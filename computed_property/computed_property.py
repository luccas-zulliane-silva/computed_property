
import json
from functools import wraps

def computed_property(func):
    """
    Decorador que guarda em memória valores de um dado cômputo para um função
    específica com base nos parâmetros fornecidos.

    Parameters
    ----------
    func : function
        Função de recebimento do decorador.
    """

    # Define caminho do cache parametrizado pelo nome da função
    cache_path = f"E:/luccas_zulliane/coding/bwgi/teste_programacao/computed_property/{func.__name__}.json"

    # Define função de leitura do cache
    def __read_cache() -> dict:
        """
        Realiza leitura do arquivo de cache.

        Returns
        -------
        dict
            Dicionário que contém o memória de cômputo.
        """

        # Realiza leitura
        with open(cache_path, 'w') as f:
            try:
                cache = json.loads(f.read())
            except:
                cache = {}
            f.flush()
            f.close()
        return cache

    # Define função de gravação do cache
    def __write_cache(cache: dict) -> None:
        """
        Realiza gravação do arquivo de cache.

        Parameters
        ----------
        cache : dict
            Dicionário que contém o memória de cômputo.
        """

        # Realiza gravação de cache
        with open(cache_path, 'w') as f:
            f.write(json.dumps(wrapper.cache))
            f.flush()
            f.close()
        return None

    @wraps(func)
    def wrapper(*args, **kwargs):
        """
        Wrapper do decorador.
        """

        # Cria variável auxiliar que representa argumentos passados para func
        _args = f"'{args}'"

        # Calcula resultado da função caso argumentos tenham sido alterados
        if _args not in wrapper.cache:
            wrapper.cache[_args] = func(*args, **kwargs)
            __write_cache(wrapper.cache)

        # Retorna resultado do cômputo
        return wrapper.cache[_args]

    # Cria atributo de cache no decorator 
    wrapper.cache = __read_cache()
    return wrapper

@computed_property
def test_function(*args) -> None:
    """
    Função de teste.
    """    
    result = 1

    for arg in args:
        result *= arg
    return result

val = test_function(1,2)
val = test_function(1,2)
val = test_function(3,4)
val = test_function(5,6)
val = test_function(7,8)
val = test_function(1,2,3,4,1,1,1,1,2)
