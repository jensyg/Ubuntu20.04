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

_ATualizar_Repositorios () {

	Logo_Empresa

	export DEBIAN_FRONTEND="noninteractive"
	
		Logo_Empresa
		echo "ATUALIZANDO O SISTEMA -- AGUARDE"
			sudo apt update -qq > /dev/null
		
		Logo_Empresa
		echo "INSTALANDO bridge-utils ifenslave net-tools AGUARDE ..."
			sudo apt -y install bridge-utils ifenslave net-tools -qq > /dev/null
		
		Logo_Empresa
		echo "FAZENDO UPGRADE --  AGUARDE"	
			sudo apt -y upgrade -qq > /dev/null
		
		Logo_Empresa
		echo "FAZENDO dist-upgrade  --  AGUARDE"
			sudo apt -y dist-upgrade -qq > /dev/null
		
		Logo_Empresa
		echo "FAZENDO full_upgrade --  AGUARDE"
			sudo apt -y full-upgrade -qq > /dev/null
		
		Logo_Empresa
		echo "FAZENDO autoremove --  AGUARDE"
			sudo apt -y autoremove -qq > /dev/null
		
		Logo_Empresa
		echo "FINALIZANDO COM autoclean  --  AGUARDE"
			sudo apt -y autoclean -qq > /dev/null
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
	cat << EOF > /etc/netplan/00-installer-config.yaml
	# Gerado pelo script Systec -- Soluçoes em TI
	# The loopback network interface

	network:
	    ethernets:
			$_INTERFACE_LAN:
				dhcp4: false
				addresses: [$_IP_STATIC/$_MASCARA]
				gateway4: $_GATEWAY
				nameservers:
					addresses: [$_GATEWAY, 8.8.8.8, 8.8.4.4]
					search: [$_NOME_DOMINIO_FQDN]
		version: 2
EOF

Logo_Empresa
echo "APLICANDO sudo netplan --debug try"
sudo netplan --debug try
read

Logo_Empresa
echo "APLICANDO netplan --debug apply"
sudo netplan --debug apply
read

Logo_Empresa
echo "APLICANDO systemd-resolve --status"
sudo systemd-resolve --status
read

Logo_Empresa
echo "APLICANDO ifconfig $_INTERFACE_LAN"
sudo ifconfig $_INTERFACE_LAN
read

Logo_Empresa
echo "APLICANDO ip address show $_INTERFACE_LAN"
sudo ip address show $_INTERFACE_LAN
read

Logo_Empresa
echo "APLICANDO route -n"
sudo route -n
read

Logo_Empresa
echo "APLICANDO ip route"
sudo ip route
read

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
		echo "VAMOS ATUALIZAR OS REPOSITORIOS -- (s/n)"
		echo ""
		echo ""
		read RESPOSTA
			if [ $RESPOSTA = "s" ] ; then
				_ATualizar_Repositorios
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
