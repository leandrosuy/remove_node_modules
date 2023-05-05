#!/usr/bin/env bash

# Define o título da janela do dialog
DIALOG_TITLE="Exclusão de pastas /node_modules"

# Define a pasta raiz para iniciar a busca
ROOT_FOLDER="/home"

# Inicia variável de controle
EXECUTAR_BUSCA=true

while [ "$EXECUTAR_BUSCA" = true ]; do
    # Busca todas as pastas /node_modules no sistema
    NODE_MODULES_FOLDERS=$(find $ROOT_FOLDER -type d -iname "node_modules")

    # Conta o número de pastas encontradas
    NUM_FOLDERS=$(echo $NODE_MODULES_FOLDERS | wc -w)

    # Exibe um aviso se não foram encontradas pastas
    if [ $NUM_FOLDERS -eq 0 ]; then
        dialog --title "$DIALOG_TITLE" --msgbox "Nenhuma pasta /node_modules encontrada." 10 50
        EXECUTAR_BUSCA=false
    else
        # Monta a lista de pastas para seleção no menu
        MENU_LIST=""
        for folder in $NODE_MODULES_FOLDERS; do
            MENU_LIST="$MENU_LIST $folder - off "
        done

        # Exibe o menu interativo com as pastas encontradas
        dialog --title "$DIALOG_TITLE" --checklist "Selecione as pastas que deseja excluir:" 20 60 $NUM_FOLDERS $MENU_LIST 2>tempfile

        # Verifica se o usuário selecionou alguma pasta
        if [ $? -eq 0 ]; then
            # Lê as pastas selecionadas do arquivo temporário
            SELECTED_FOLDERS=$(cat tempfile)

            # Remove pastas duplicadas da lista de pastas selecionadas
            SELECTED_FOLDERS=$(echo "$SELECTED_FOLDERS" | tr ' ' '\n' | sort | uniq | tr '\n' ' ')

            # Pergunta ao usuário se deseja excluir as pastas selecionadas
            dialog --title "$DIALOG_TITLE" --yesno "Deseja excluir as pastas selecionadas?" 10 50

            # Verifica se o usuário confirmou a exclusão
            if [ $? -eq 0 ]; then
                # Exclui as pastas selecionadas
                rm -rf $SELECTED_FOLDERS
                dialog --title "$DIALOG_TITLE" --msgbox "Pastas excluídas com sucesso." 10 50
            else
                dialog --title "$DIALOG_TITLE" --msgbox "Exclusão cancelada pelo usuário." 10 50
            fi
        else
            # Usuário cancelou a seleção de pastas
            dialog --title "$DIALOG_TITLE" --msgbox "Operação cancelada pelo usuário." 10 50
        fi
    fi

    # Pergunta ao usuário se deseja executar outra busca
    dialog --title "$DIALOG_TITLE" --yesno "Deseja executar outra busca?" 10 50

    # Verifica se o usuário deseja executar outra busca
    if [ $? -eq 0 ]; then
        EXECUTAR_BUSCA=true
    else
        EXECUTAR_BUSCA=false
    fi
done

# Remove o arquivo temporário
rm -f tempfile
