# setup_ejson.sh

PUBLIC_KEY=$(bundle exec ejson --keydir=ejson keygen -w)
echo $PUBLIC_KEY
echo "{\"_public_key\": \"$PUBLIC_KEY\", \"tba_api_key\": \"abcd1234\"}" > ${BASH_SOURCE%/*}/../ejson/secrets.ejson
bundle exec ejson --keydir=ejson encrypt ejson/secrets.ejson
