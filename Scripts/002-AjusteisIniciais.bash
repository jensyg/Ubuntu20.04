#!/usr/bin/env bash
source 001-Variaveis.sh

EMPRESA=SYSTEC

Logo_Empresa () {
	clear
	echo ""
	echo -e " \e[1;31m =================================================================== \e[m ";
	figlet -c "$EMPRESA"
	echo -e " \e[1;31m =================================================================== \e[m ";
	echo ""
	echo ""
	return
}

_Comparar_String () {
	Logo_Empresa
		local Var1=$_String_a_Comparar
		local Var2=$_Minha_Escrita

		while [ ["$Var1" != "$Var2" ] ]; do
			if [ "$?" = "0" ] ; then
				Logo_Empresa
				echo "TEVE UM ERRO NA ESCRITA"
				echo "VAMOS TENTAR DE NOVO"
				echo -e '\e[34;1;3m' "$_String_a_Comparar \e[m";
				read nuevo
				Var2=$nuevo
			fi
		done 
}



_Arquivo_Hostname () {
	cat <<EOF > /etc/hostname
	# Gerado pelo script Systec -- Soluçoes em TI

	$_NOME_SERVIDOR
EOF
}

_Arquivo_Hosts () {
	cat << EOF > /etc/hosts
	# Gerado pelo script Systec -- Soluçoes em TI

	127.0.0.1 	localhost 
	127.0.0.1	$_NOME_SERVIDOR.$_NOME_DOMINIO_FQDN $_NOME_SERVIDOR
EOF
}

_Arquivo_Resolv_Conf () {
	cat << EOF > /etc/resolv.conf
	# Gerado pelo script Systec -- Soluçoes em TI

	domain $_NOME_DOMINIO_FQDN
	search $_NOME_DOMINIO_FQDN
	nameserver 127.0.0.1
EOF
}

_Arquivo_Interfaces () {
	cat << EOF > /etc/network/interfaces
	# Gerado pelo script Systec -- Soluçoes em TI
	# The loopback network interface

	source /etc/network/interfaces.d/*	
	
	auto lo
	iface lo inet loopback
	
	allow-hotplug $_LAN
		iface $_LAN inet static
		address $_IP
		netmask $_MASCARA
		network $_NETWORK
		gateway $_GATEWAY
EOF
}

_Servico_SSH () {
	echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
	/ssh/init.d/ssh restart
	if [ "$?" = 0 ] ; then
		/ssh/init.d/ssh status
		read
	fi	
}





clear
echo -e "carregando..."
DEBIAN_FRONTEND=noninteractive
export DEBIAN_FRONTEND
EMPRESA=SYSTEC
	pacote=$(dpkg --get-selections | grep "figlet" )
		if [ -n "$pacote" ] ;then
			echo
		else
			apt-get install figlet -qq > /dev/null
		fi

		clear
		Logo_Empresa
		echo "VAMOS CONFIGURAR EL ARQUIVO HOSTNAME -- (s/n)"
		echo ""
		echo ""
		read RESPOSTA
			if [ $RESPOSTA = "s" ] ; then
				_Arquivo_Hostname
			fi

	clear
		Logo_Empresa
		echo "VAMOS CONFIGURAR EL ARQUIVO HOSTS -- (s/n)"
		echo ""
		echo ""
		read RESPOSTA
			if [ $RESPOSTA = "s" ] ; then
				_Arquivo_Hosts
			fi

	clear
		Logo_Empresa
		echo "VAMOS CONFIGURAR EL ARQUIVO RESOLV.CONF -- (s/n)"
		echo ""
		echo ""
		read RESPOSTA
			if [ $RESPOSTA = "s" ] ; then
				_Arquivo_Resolv_Conf
			fi



	clear
		Logo_Empresa
		echo "VAMOS CONFIGURAR EL ARQUIVO INTERFACES -- (s/n)"
		echo ""
		echo ""
		read RESPOSTA
			if [ $RESPOSTA = "s" ] ; then
				_Arquivo_Interfaces
				ip addr flush dev $_LAN
				sleep 1
				ifdown $_LAN
				sleep 1
				ifup $_LAN
				sleep 1
				ping -c 2 google.com
					if [ "$?" = 0 ] ; then
						echo -e "\e[1;32m PARABENS !! SEU SERVIDOR ESTA CONECTADO A INTERNET PODEMOS CONTINUAR  \e[m";
						echo ""
						echo -e "\e[1;32m ENTER PARA CONTINUAR  \e[m";
						read
					fi
			fi


	clear
		Logo_Empresa
		echo "VAMOS CONFIGURAR EL SERVICO SSH -- (s/n)"
		echo ""
		echo ""
		read RESPOSTA
			if [ $RESPOSTA = "s" ] ; then
				_Servico_SSH
			fi	

exit
