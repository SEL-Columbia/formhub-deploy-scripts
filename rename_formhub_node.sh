if [ -f ".formhub_node_name" ]
then
    echo ""
    echo "Deleting existing formhub node name: `cat .formhub_node_name`"
    echo ""
    rm -f .formhub_node_name
fi

sh name_formhub_node.sh