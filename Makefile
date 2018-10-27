index_lambda_payload = terraform/build/index.zip
index_lambda_contents = lambda/index/index.js

all: site

$(index_lambda_payload): $(index_lambda_contents)
	zip -j -o $(index_lambda_payload) $(index_lambda_contents)

.PHONY: site
site:
	hugo


clean:
	- rm -r public
