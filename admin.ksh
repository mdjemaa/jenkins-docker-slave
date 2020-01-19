#!/bin/sh

## ==========================================================================================
## Script de démarrage, d'arret et de notification de statut
## pour les différentes instances de HUDSON
##
## Utilisation :
## admin.ksh <commande> <nom de l'instance>
##
## Exemple : 	admin.ksh start 1.2
##				démarre l'instance indiquée dans le fichier ../instances/1.2.config
##
## ==========================================================================================
## Historique des modifications:
##
## SCR 10/02/10: Version initiale
## JPL 01/06/2010: Modifs pour v1.321
## MLE 10/06/2010 : Modifs pour installer plusieurs instances sur psd216 (ports ajp13 et udp) et 
## 		factorisation du script pour les differents environnements
## MLE 04/07/2010 : utilisation de fichier de conf pour les differentes instances
## MLE 26/08/2010 : Intégration du mode "all instances"
## MLE 08/11/2010 : Réorganisation de la structure des repertoires de l'usine (prod, int, test > version)
## MLE 08/12/2010 : Ajout des options memoire java pour le start
## FANNANE 05/06/2012 : Migration hudson vers jenkins 1.ajout param dump | 2. chg hudson>jenkins
##
## ==========================================================================================
# Environnement

. ${UDD_COMMON_FCT}
ulimit -c 0 2>/dev/null

## ==========================================================================================

## Constantes

export JAVA_HOME=/opt/java6
export PATH=$PATH:$JAVA_HOME/bin
export SNAPSHOT=0.4-SNAPSHOT

#export readonly JMX_OPTS='-Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.port=30000 -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmx.remote.ssl=false'

readonly HUDSON_INSTALL_DIR=${UDD_SOFT_DIR}/${UDD_HUDSON}
readonly HUDSON_WAR_DIR=${HUDSON_INSTALL_DIR}/war

## ==========================================================================================
## Controle des parametres

NB_EXPECTED_PARAMS=2

echo ""
if [ $# -ne ${NB_EXPECTED_PARAMS} ]; then
	echo "Nombre de parametres incorrect, ${NB_EXPECTED_PARAMS} attendus, $# recu(s)"
	echo 'Utilisation : admin.ksh <start|stop|status> <nom instance>\n'
	exit 1
fi

readonly COMMAND=$1
readonly INSTANCE_NAME=$2

if [ ${COMMAND} != "start" -a  ${COMMAND} != "stop" -a ${COMMAND} != "status" ]; then
	echo "La valeur du 1er parametre est incorrecte"
	echo 'Utilisation : admin.ksh <start|stop|status> <nom instance>\n'
	exit 1
fi

## ==========================================================================================
# Mode ALL : execution de la commande sur toutes les instances trouvees

readonly ALL_INSTANCES='ALL'

if [ ${INSTANCE_NAME} = ${ALL_INSTANCES} ]; then
	for instance in ${UDD_PRODUCTION} ${UDD_INTEGRATION} ${UDD_TEST}
	do
		echo "\nInstance PCP ${instance} :"
		$0 ${COMMAND} ${instance}
	done
	exit 0
fi

## ==========================================================================================
# Lecture des fichiers de configuration de l'instance

readonly PORT_CONFIG_FILE=${UDD_BASE_DIR}/${INSTANCE_NAME}/${UDD_PORTS_CFG_FILE}
readonly HTTP_PARAM="hudson.http"
readonly UDP_PARAM="hudson.udp"
export HUDSON_HTTP_PORT=`readParam ${PORT_CONFIG_FILE} ${HTTP_PARAM}`
if [ $? != 0 -o `echo ${HUDSON_HTTP_PORT} | wc -c` -le 1 ]; then
	echo "Erreur lors de la lecture du parametre ${HTTP_PARAM} dans fichier ${PORT_CONFIG_FILE}\n"
	exit 1
fi
export HUDSON_UDP_PORT=`readParam ${PORT_CONFIG_FILE} ${UDP_PARAM}`
if [ $? != 0 -o `echo ${HUDSON_UDP_PORT} | wc -c` -le 1 ]; then
	echo "Erreur lors de la lecture du parametre ${UDP_PARAM} dans fichier ${PORT_CONFIG_FILE}\n"
	exit 1
fi

readonly VERSION_CONFIG_FILE=${UDD_SOFT_DIR}/${UDD_HUDSON}/config/hudson_instances_versions.cfg
export HUDSON_VERSION=`readParam ${VERSION_CONFIG_FILE} ${INSTANCE_NAME}`
if [ $? != 0 -o `echo ${HUDSON_VERSION} | wc -c` -le 1 ]; then
	echo "Erreur lors de la lecture du parametre ${INSTANCE_NAME} dans fichier ${VERSION_CONFIG_FILE}\n"
	exit 1
fi

## ==========================================================================================
# Constantes

UDD_HOME=${UDD_BASE_DIR}/${INSTANCE_NAME}/${UDD_CURRENT}
export HUDSON_HOME=${UDD_HOME}/${UDD_HUDSON}
TMP_DIR=${UDD_HOME}/tmp
CHEMIN_DUMP_JVM=${UDD_HOME}/dump
NOHUP_LOGFILE=${UDD_HOME}/logs/hudson_$(date +%y%m%dT%H%M).log
HUDSON_WAR_FILE=jenkins-${HUDSON_VERSION}.war
HUDSON_WAR=${HUDSON_WAR_DIR}/${HUDSON_WAR_FILE}
FIND_PID="ps -exf | grep ${HUDSON_WAR_FILE} | grep httpPort=${HUDSON_HTTP_PORT} | grep -v grep | awk '{ print "'$2'" }'"

## ==========================================================================================

case ${COMMAND} in
''|start)
    # Demarrage du serveur
	pid=`eval ${FIND_PID}`
    if [[ "xx$pid" = "xx" ]]; then	
		echo "Demarrage de JENKINS v${HUDSON_VERSION} dans ${HUDSON_HOME}, port HTTP: ${HUDSON_HTTP_PORT}, port UDP: ${HUDSON_UDP_PORT}"
		echo "Log : ${NOHUP_LOGFILE}\n"
		nohup java -Xms256M -Xmx2048M -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=${CHEMIN_DUMP_JVM} ${JMX_OPTS} -Dhudson.udp=${HUDSON_UDP_PORT} -Djava.io.tmpdir=${TMP_DIR} -jar ${HUDSON_WAR} --httpPort=${HUDSON_HTTP_PORT} --ajp13Port=-1 --prefix= >> ${NOHUP_LOGFILE} 2>&1 &
    else
		echo "Cette instance JENKINS est deja demarree (PID: $pid).\nUtilisez au prealable la commande stop pour l'arreter.\n" 
	fi
    ;;

''|status)
    # Statut du serveur
    pid=`eval ${FIND_PID}`
    if [[ "xx$pid" = "xx" ]]; then
      # pas de PID - JENKINS n'est pas demarre
      echo "Cette instance JENKINS est arretee.\n"
    else
      # On a le PID de JENKINS dans $pid, il est demarre
      echo "Cette instance JENKINS est demarree (PID: $pid).\n"
    fi
    ;;

''|stop)
    # Arret du serveur
	pid=`eval ${FIND_PID}`	
	if [ "xx$pid" = "xx" ]; then
		echo "Le processus ${HUDSON_WAR_FILE} en écoute sur le port ${HUDSON_HTTP_PORT} est deja arrete.\n"
	else
		nbProcess=`eval ${FIND_PID} | wc -l`		
		if [ ${nbProcess} -eq 1 ]; then
			echo "Arret du processus ${HUDSON_WAR_FILE} en écoute sur le port ${HUDSON_HTTP_PORT} (PID : ${pid})\n"
			kill -9 ${pid}
		else
			echo "ERREUR, le nombre de process correspondants est different de 1 : ${nbProcess}\n"	
		fi
	fi
    ;;
esac

from lxml import etree

tree = etree.parse("thefile.xml")
my_list = []
for user in tree.xpath("/map/entry[string='global']/list/string"):
    my_list.append(user.text)
print (my_list)

