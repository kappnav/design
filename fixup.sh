for md in *.md; do 
	sed "s|https://github.ibm.com/WASCloudTribe/design/blob/master/prism|https://github.com/kappnav/design/blob/master|g" $md > tmp
	rm $md 
	mv tmp $md 
done
