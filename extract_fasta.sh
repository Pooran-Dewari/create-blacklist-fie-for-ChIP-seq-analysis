for file in *fa.gz
do
 echo "now gunzipping $file"
 gunzip $file
done
