# Arch Config

Este projeto automatiza a configuração inicial de um sistema Arch Linux. O script `bootstrap.sh` realiza as seguintes tarefas:

## Funcionalidades

1. Configuração de timezone e idioma:

   - Define o timezone para America/Sao_Paulo.
   - Configura o relógio do hardware.
   - Gera as configurações de locale.
   - Define o layout do teclado.
   - Define o hostname do sistema.

2. Configuração do `mkinitcpio` com hooks para criptografia LUKS:

   - Atualiza o arquivo `/etc/mkinitcpio.conf` com os hooks necessários.
   - Gera a imagem inicial do sistema.

3. Configuração do GRUB:

   - Solicita ao usuário o container criptografado e a localização da partição root.
   - Obtém os UUIDs dos dispositivos fornecidos.
   - Atualiza o arquivo `/etc/default/grub` com as informações de criptografia e root.
   - Instala o GRUB no diretório EFI fornecido pelo usuário.
   - Cria a configuração do GRUB.

4. Configuração de usuário:

   - Define a senha do usuário root.
   - Cria um novo usuário e define sua senha.
   - Adiciona o novo usuário ao grupo `wheel` e configura sudo.

5. Habilitação de serviços:
   - Habilita o `NetworkManager`.
   - Habilita a sincronização de tempo com `systemd-timesyncd`.
