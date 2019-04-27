# run custom tasks
if [ ! -z "$CONFIG_CUSTOM_TASKS" ]; then
	for TASK_NAME in $CONFIG_CUSTOM_TASKS; do
		TASK_NAME=$(echo $TASK_NAME | xargs)
		TASK="$SCRIPTPATH/tasks/$TASK_NAME.sh"
		echo "--------------------------------"
		info "running $TASK"

		if [ -f "$TASK" ]; then
			source "$TASK"
		else
			error "task $TASK_NAME not found"
		fi
	done
fi

