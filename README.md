# Backup de Documentos (Windows)

Script PowerShell para copiar a pasta de documentos do usuário para uma pasta de backup local usando `robocopy`.

## Requisitos

- Windows com PowerShell 5.1 ou superior.
- `robocopy` disponível (nativo do Windows).

## Padrões

- Origem: `%USERPROFILE%\Documents`
- Destino: `C:\Backup\Documents`
- Pastas excluídas: `Imagens`, `Pictures`, `Videos`, `Music`, `Músicas`
- Log: `%TEMP%\BackupDocuments.log` (acrescentado a cada execução)

## Uso

### Windows

Duplo clique em `Run.bat`.

Ou execute pelo PowerShell:

```powershell
.\BackupDocuments.ps1
```

### Personalizando

```powershell
.\BackupDocuments.ps1 -Source "D:\Documentos" -Destination "E:\Backup\Documentos"
```

Somente listar o que seria copiado, sem copiar:

```powershell
.\BackupDocuments.ps1 -ListOnly
```

Excluir outras pastas:

```powershell
.\BackupDocuments.ps1 -ExcludeDirs "Temp", "Cache", "Node_Modules"
```

Usar outro log:

```powershell
.\BackupDocuments.ps1 -LogPath "E:\Backup\backup.log"
```

Desativar o log:

```powershell
.\BackupDocuments.ps1 -LogPath ""
```

## Parâmetros

| Parâmetro | Padrão | Descrição |
|---|---|---|
| `-Source` | `$HOME\Documents` | Pasta de origem. |
| `-Destination` | `C:\Backup\Documents` | Pasta de destino. |
| `-ExcludeDirs` | `Imagens`, `Pictures`, `Videos`, `Music`, `Músicas` | Nomes de pastas ignoradas pelo `robocopy`. |
| `-LogPath` | `%TEMP%\BackupDocuments.log` | Arquivo de log. Use `""` para desativar. |
| `-ListOnly` | desligado | Adiciona `/L` ao `robocopy` para apenas listar. |

## Flags do robocopy

- `/E`: inclui subpastas, inclusive vazias.
- `/Z`: permite retomar transferências interrompidas.
- `/R:2` e `/W:5`: limitam tentativas e espera entre elas.
- `/XO`: não sobrescreve arquivos mais novos no destino.
- `/XJ`: ignora junções e pontos de junção.
- `/XD`: exclui as pastas informadas.
- `/L`: apenas lista, sem copiar.
- `/LOG+` e `/TEE`: gravam o log e também mostram a saída no console.

## Códigos de saída

O script considera sucesso os códigos `0` a `7` do `robocopy`. Códigos `8` ou maiores são tratados como erro e retornados ao chamador.

## Agendamento

No Agendador de Tarefas do Windows, use:

```text
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\caminho\para\BackupDocuments.ps1"
```

## Segurança

- O script não contém caminhos pessoais, tokens ou senhas.
- O destino não pode ser igual ou estar dentro da origem; isso evita cópia recursiva.
- Logs e arquivos temporários são ignorados pelo Git.
- Prefira um destino de backup fora do disco ou da pasta de origem.

## Observações

- O modo padrão copia arquivos novos ou alterados, mas não remove do destino arquivos que foram apagados da origem.
- Para espelhar a origem no destino, seria necessário usar `/MIR`; faça isso apenas com cautela, pois ele exclui arquivos extras no destino.

## Estrutura

```text
.
├── BackupDocuments.ps1   # script principal
├── Run.bat               # atalho para execução no Windows
├── README.md
└── .gitignore
```
