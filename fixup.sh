for md in *.md; do 
	l=$(cat $md | sed "s|https://github.ibm.com/WASCloudTribe/design/blob/master/prism|https://github.com/kappnav/design/blob/master|")
	echo $l >$md
done
