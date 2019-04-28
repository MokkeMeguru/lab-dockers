#! /bin/bash

# export UID=${UID}
# export GID=${GID}

# function reformat_name () {
#     for raw_name in "$@"
#     do
#         echo $(echo $(basename $raw_name) | sed -e 's/.dockerfile//g')
#     done
# }

# # select framework
# echo "Please choose the framework you want"
# select TYPE in tensorflow pytorch exit
# do
#     if [ "$TYPE" = "exit" ];
#     then
#         echo "[INFO] EXIT"
#         break
#     else
#         break
#     fi
# done

# # select version
# echo "[INFO] I will build jupyterlab for $VAR ..."
# VARLIST=$(find "./jupyterlabs/$TYPE" "-type" "f")
# select VER in $(reformat_name $VARLIST)
# do
#     echo "$VER"
#     break
# done

# # check existance of running container
# if [ "" = $(docker ps -q --f name=="${VER}_${USER}") ];
# then
#     "I think you can access your docker image Please"
#     echo "none"
# else
#     echo "None"
# fi


# docker build --no-cache=true -t "$VER" -f "./jupyterlabs/$VER.dockerfile"
# docker build --no-cache=true -t tensorflow-1.12:v1 -f tensorflow-1.12.dockerfile .

 # docker run --rm -d -u=$(id -u):$(id -g) \
 #       -v /home/$USER:/home/$USER -v /etc/passwd:/etc/passwd:ro -v /etc/group:/etc/group:ro \
 #       --name "${VER}_${USER}" \
 #       "$VER"
#  docker run --rm -d -it \
#        -v /home/$USER:/home/$USER -v /etc/passwd:/etc/passwd:ro -v /etc/group:/etc/group:ro \
#        tensorflow-1.12:v1

#  docker run --rm -d  \
#         -p 8000:8000 \
#         -v /home/:/home/ -v /etc/passwd:/etc/passwd:ro -v /etc/group:/etc/group:ro \
#         -v /etc/shadow:/etc/shadow:ro -v /etc/sudoers.d:/etc/sudoers.d:ro \
#         tensorflow-1.12:v1
