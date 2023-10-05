#!/bin/bash

TIMEOUT_PREFIX=timeout-

SWAYIDLE_ARGS=()

CONFS=$HOME/.config/swayidle

cmd() {
	echo "find '$CONFS/$1' -type f -executable -name '*.sh' -exec bash {} \\;"
}


while read -r d
do
	if [[ ! -d "$CONFS/$d" ]]
	then
		echo "$CONFS/$d is not a directory" >&2
		continue
	fi

	case "$d" in
		"$TIMEOUT_PREFIX"*-resume.d) ;;
		"$TIMEOUT_PREFIX"*.d)
			TIME=${d#"$TIMEOUT_PREFIX"}
			TIME=${TIME%.d}
			SWAYIDLE_ARGS+=(timeout "$TIME" "$(cmd "$d")")
			r="$TIMEOUT_PREFIX$TIME-resume.d"
			if [[ -d "$CONFS/$r" ]]
			then
				SWAYIDLE_ARGS+=(resume "$(cmd "$r")")
			fi
			;;
		before-sleep.d) SWAYIDLE_ARGS+=(before-sleep "$(cmd "$d")"); SWAYIDLE_ARGS=("-w" "${SWAYIDLE_ARGS[@]}") ;;
		after-resume.d) SWAYIDLE_ARGS+=(after-resume "$(cmd "$d")") ;;
		lock.d) SWAYIDLE_ARGS+=(lock "$(cmd "$d")") ;;
		unlock.d) SWAYIDLE_ARGS+=(unlock "$(cmd "$d")") ;;
		*) echo "Unknown conf $CONFS/$d" >&2 ;;
	esac
done < <(ls -AL "$CONFS")

swayidle "${SWAYIDLE_ARGS[@]}"
