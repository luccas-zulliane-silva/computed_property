
# Bibliotecas padrao
import io
import os

def last_lines(file: str, buffer_size=io.DEFAULT_BUFFER_SIZE):
    """_summary_

    Parameters
    ----------
    file : str
        _description_
    buffer_size : _type_, optional
        _description_, by default io.DEFAULT_BUFFER_SIZE

    Returns
    -------
    _type_
        _description_

    Raises
    ------
    TypeError
        _description_
    FileNotFoundError
        _description_
    """

    # Define array de linhas
    lines = []

    # Verifica tipo do argumento
    if not isinstance(file, str):
        raise TypeError(f"Parâmetro filename deve ser tipo str, não {type(file)}.")

    # Verifca existência do arquivo de leitura
    if not os.path.exists(file):
        raise FileNotFoundError(f"Não pode encontrar caminho especificado em {file}.")

    # Realiza leitura de arquivo
    with open(file, encoding='utf-8') as f:

        # Define chunk de leitura
        chunk = ''

        # Vai para o final do arquivo
        f.seek(0, 2)

        # Obtém posição de leitura atual
        pos = f.tell()
        left = pos

        while pos > 0:

            # Obtém nova posição
            pos = max(0, pos-buffer_size)

            # Define nova posição de leitura
            f.seek(pos)

            # Realiza leitura
            pre = f.read(min(buffer_size, left))
            chunk = (pre if '\n' not in pre else pre[:-1])+chunk

            # Conta quantas leituras faltam
            left = max(0, left - buffer_size)

            if '\n' in chunk:
                chunks = list(reversed(chunk.split('\n')))
                for c in chunks[:-1]:
                    lines.append(c)
                chunk = chunks[-1]
                if pos == 0:
                    lines.append(chunk)
            elif pos == 0:
                lines.append(chunk)

    if lines:
        lines = [f"{ii}\n" for ii in lines]

    # Retorna últimas linhas do arquivo
    return iter(lines)

if __name__ == '__main__':
    for line in last_lines(file=r'E:/luccas_zulliane/coding/bwgi/teste_programacao/last_lines/my_file.txt', buffer_size=700):
        print(line, end='')
