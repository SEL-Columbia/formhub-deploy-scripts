if [ ! -f ".formhub_node_id" ]
then
    echo `ifconfig | grep ether | head -n1 | md5sum | cut -c 1-5` > .formhub_node_id
fi
export FORMHUB_NODE_ID=`cat .formhub_node_id`

if [ ! -f ".formhub_node_name" ]
then
    echo "What is the name of this Formhub Node? (ie. Where will it be used?)"
    echo "  Example: 'New York City' or 'Haiti West'"
    read node_name
    echo "Saving node name: $node_name"
    echo "$node_name" > .formhub_node_name
fi
