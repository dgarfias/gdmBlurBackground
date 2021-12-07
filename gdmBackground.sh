gst=/usr/share/gnome-shell/gnome-shell-theme.gresource
bgName=loginBackground.png
res="$(xrandr --current | sed -n 's/.* connected \([0-9]*\)x\([0-9]*\)+.*/\1x\2/p')"
resCss="$(echo $res | sed 's/x/px /g')px"

for r in `gresource list $gst`; do
	r=${r#\/org\/gnome\/shell/}
	if [ ! -d $(pwd)/${r%/*} ]; then
	  mkdir -p $(pwd)/${r%/*}
	fi
done

for r in `gresource list $gst`; do
        gresource extract $gst $r >$(pwd)/${r#\/org\/gnome\/shell/}
done

# 78x26
convert $1 -channel RGBA -blur 0x60 +level 0x55% -resize "$res"! "theme/$bgName"

echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<gresources>
  <gresource prefix=\"/org/gnome/shell/theme\">
$(find theme/ -type f | sed 's/theme\//   <file>/g' | sed 's/$/<\/file>/')
  </gresource>
</gresources>" >> theme/gnome-shell-theme.gresource.xml

oldBg="#lockDialogGroup \{.*?\}"
newBg="#lockDialogGroup {
  background: url('resource:\/\/\/org\/gnome\/shell\/theme\/$bgName');
  background-size: $resCss;
  background-repeat: no-repeat; }"
  
oldOverview="#overviewGroup \{.*?\}"
newOverview="#overviewGroup {
  background: url('resource:\/\/\/org\/gnome\/shell\/theme\/$bgName');
  background-size: $resCss;
  background-repeat: no-repeat; }"

perl -i -0777 -pe "s/$oldBg/$newBg/s" theme/gnome-shell.css
perl -i -0777 -pe "s/$oldOverview/$newOverview/s" theme/gnome-shell.css

glib-compile-resources --sourcedir=$(pwd)/theme/ $(pwd)/theme/gnome-shell-theme.gresource.xml

if [ -f "/usr/share/gnome-shell/gnome-shell-theme.gresource.bak" ]; then
    sudo rm /usr/share/gnome-shell/gnome-shell-theme.gresource.bak
fi

sudo mv /usr/share/gnome-shell/gnome-shell-theme.gresource /usr/share/gnome-shell/gnome-shell-theme.gresource.bak
sudo cp theme/gnome-shell-theme.gresource /usr/share/gnome-shell/

rm theme -R
