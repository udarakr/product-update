#!/bin/sh
# declare variables
WUM_PATH=~/.wum-wso2
PRODUCT_AM="wso2am"
PRODUCT_AM_VERSION="2.1.0"
PRODUCT_AM_SUBTHEME="wso2-new"
PRODUCT_AM_PATH=src/$PRODUCT_AM-$PRODUCT_AM_VERSION/repository/deployment/server/jaggeryapps/store/site/

# Start of function definitions

install_dependencies(){
	#TODO WUM, UNZIP, GIT (or download to src)
	echo Installing dependencies...
	#sudo apt-get install jq
}

wum_init(){
	echo Initializing WSO2 Update Manager...
	wum init;
}

wum_add(){
	echo Adding required WSO2 Products...
	wum add $1; #move to a variable
}

wum_update(){
	echo Updating $PRODUCT_AM-$PRODUCT_AM_VERSION...
	wum_add $PRODUCT_AM-$PRODUCT_AM_VERSION;
	wum update $PRODUCT_AM-$PRODUCT_AM_VERSION;
}

clean_src(){
	echo Removing temporary files inside src...
	rm -r src/$PRODUCT_AM-$PRODUCT_AM_VERSION
}

get_updated_file(){
	OUTPUT="$(ls -t $WUM_PATH/products/$PRODUCT_AM/$PRODUCT_AM_VERSION/$PRODUCT_AM-$PRODUCT_AM_VERSION* | head -n 1)"
	echo $OUTPUT
	clean_src
	unzip $OUTPUT -d src/
	#copy financial-solutions sub-theme
	cp -r src/$PRODUCT_AM_SUBTHEME $PRODUCT_AM_PATH/themes/
}

update_conf(){
	#Update theme within site.json
	#tmp=$(mktemp)
	#jq theme.base = $PRODUCT_AM_SUBTHEME $PRODUCT_AM_PATH/conf/site.json > "$tmp" && mv "$tmp" $PRODUCT_AM_PATH/conf/site.json
	# sed "s/\('environmentName':\)/\1\"prod\"\,/g" version.json
	# CONF=cat site.json
	# echo $CONF | sed 's/\({"base":"\)[^"]*\("}\)/\1wso2-new\2/g' > $tmp
	echo Updating the site.json...
	sed -i 's/"base" : "wso2"/"base" : "wso2-new"/g' $PRODUCT_AM_PATH/conf/site.json
}

# End of function definitions

#run wum command to validate the environment
install_dependencies;
wum &> /dev/null;
if [ $? -eq 0 ]; then
	#wum installed
    wum_update;
    get_updated_file;
    update_conf;
else
	#exec wum init
    wum_init;
    wum_add AM_VERSION;
fi
