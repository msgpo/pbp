#!/usr/bin/ksh

rm -rf ./test-pbp
echo create some keys
echo create alice
pbp -g -n alice -b ./test-pbp || exit
echo create bob
pbp -g -n bob -b ./test-pbp || exit
echo create carol
pbp -g -n carol -b ./test-pbp || exit

# test msg
cat >./test-pbp/howdy.txt <<EOF
hello world
EOF

echo public key crypto test
pbp -c -S alice -r bob -i ./test-pbp/howdy.txt -b ./test-pbp || exit
echo decrypt
pbp -d -S bob -i ./test-pbp/howdy.txt.pbp -b ./test-pbp || exit

echo "too many recipient pk crypto test (should fail)"
echo "howdy" | pbp -c -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r alice -S bob -b ./test-pbp/ | pbp -d -S alice -b ./test-pbp && exit

echo "max_recipient recipient pk crypto test"
echo "howdy" | pbp -c -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r alice -S bob -b ./test-pbp/ | pbp -d -S alice -b ./test-pbp || exit

echo "many recipient pk with max-recipients and correct sender"
echo "howdy" | pbp -c -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r alice -S bob -b ./test-pbp/ | pbp -d --sender bob --max-recipients 100 -S alice -b ./test-pbp

echo "many recipient pk with max-recipients and wrong sender"
echo "howdy" | pbp -c -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r carol -r alice -S bob -b ./test-pbp/ | pbp -d --sender alice --max-recipients 100 -S alice -b ./test-pbp && exit

echo secret key crypto test
pbp -c -i ./test-pbp/howdy.txt || exit
echo decrypt
pbp -d -i ./test-pbp/howdy.txt.pbp || exit

echo public key signature test
pbp -s -S alice -i ./test-pbp/howdy.txt -b ./test-pbp || exit
echo verify
pbp -v -i ./test-pbp/howdy.txt.sig -b ./test-pbp || exit

echo some key signing tests
pbp -m -S alice -n bob -b ./test-pbp || exit
pbp -m -S alice -n carol -b ./test-pbp || exit
pbp -m -S bob -n carol -b ./test-pbp || exit

echo check sigs on carols key
pbp -C -n carol -b ./test-pbp || exit
pbp -C -n bob -b ./test-pbp || exit

echo test PFS mode
rm ./test-pbp/sk/.alice/bob ./test-pbp/sk/.bob/alice /tmp/[24]bob* /tmp/[24]alice*
pbp -e -S alice -r bob -b ./test-pbp -i ./test-pbp/howdy.txt -o /tmp/2bob || exit
pbp -E -S bob -r alice -b ./test-pbp/ -i /tmp/2bob || exit
pbp -e -S bob -r alice -b ./test-pbp/ -i ./test-pbp/howdy.txt -o /tmp/2alice || exit
pbp -E -S alice -r bob -b ./test-pbp/ -i /tmp/2alice || exit
pbp -e -S alice -r bob -b ./test-pbp -i ./test-pbp/howdy.txt -o /tmp/2bob || exit
pbp -E -S bob -r alice -b ./test-pbp/ -i /tmp/2bob || exit
pbp -e -S bob -r alice -b ./test-pbp/ -i ./test-pbp/howdy.txt -o /tmp/2alice || exit
pbp -E -S alice -r bob -b ./test-pbp/ -i /tmp/2alice -o /tmp/4alice || exit
echo test some repeated msgs
pbp -e -S alice -r bob -b ./test-pbp -i ./test-pbp/howdy.txt -o /tmp/2bob || exit
pbp -e -S alice -r bob -b ./test-pbp -i ./test-pbp/howdy.txt -o /tmp/2bob-2 || exit
pbp -E -S bob -r alice -b ./test-pbp/ -i /tmp/2bob || exit
pbp -E -S bob -r alice -b ./test-pbp/ -i /tmp/2bob-2 || exit
pbp -e -S bob -r alice -b ./test-pbp/ -i ./test-pbp/howdy.txt -o /tmp/2alice || exit
pbp -E -S alice -r bob -b ./test-pbp/ -i /tmp/2alice -o /tmp/4alice || exit

echo testing random number streaming
pbp -R -Rs 99999999 | pv -ftrab >/dev/null

echo testing multiparty DH
pbp -Ds -S alice -b test-pbp -Dp 3 -n 'test-dh' -i /dev/null -o /tmp/dh1
pbp -Ds -S bob -b test-pbp -Dp 3 -n 'test-dh' -i /tmp/dh1 -o /tmp/dh2
pbp -Ds -S carol -b test-pbp -Dp 3 -n 'test-dh' -i /tmp/dh2 -o /tmp/dh3
pbp -De -S alice -b test-pbp -Dp 3 -n 'test-dh' -i /tmp/dh3 -o /tmp/dh4
pbp -De -S bob -b test-pbp -Dp 3 -n 'test-dh' -i /tmp/dh4 -o /tmp/dh5

echo testing import / export
rm -rf ./test-pbp/other
echo create tom with separate keyring
pbp -g -n tom -b ./test-pbp/other || exit
echo import alice to toms keyring, and vice versa
pbp -x -b ./test-pbp -S alice | pbp -I -b ./test-pbp/other
pbp -x -b ./test-pbp/other -S tom | pbp -I -b ./test-pbp
echo encrypt to alice from tom, and try to decrypt it immediately
echo "howdy" | pbp -c -r alice -S tom -b ./test-pbp/other | pbp -d -S alice -b ./test-pbp
