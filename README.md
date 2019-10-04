HelloSign Downloader
================

CLI tool to download documents from HelloSign by using the signature uuid or a query string

Installation
------------

Just clone the repository and execute:

```bash
$ bundle install
```

Configuration
-------------
Copy the file [.env.example](.env.example) and rename it as __.env__. Then
fill the variables *HELLO_SIGN_API_KEY* and *HELLO_SIGN_CLIENT_ID* with your credentials.

How it works
------------
This project is created to perform a really short subset of actions which the main one is
to download documents. The available commands are:
* Download document(s) using their document id
```bash
$ bin/hs download document1_id document2_id
```
 * There are some flags that you could use to customize the download:
   * -f, --format: Available options are PDF and ZIP (Default: PDF)
   * -o, --output: Download folder


* You can also make queries to HelloSign to retrieve some information about your
documents. To get a more extensive list of query options you can visit
[HelloSign](https://app.hellosign.com/api/reference#Search):
```bash
$ bin/hs query complete:true
```
 * There are some flags that you could use to control the returned feed:
   * -p, --page: Page number
   * -l, --limit: Limit items on page (Default: 20, Max: 100)


* Then you may want to get some information about the document by its ID:
```bash
$ bin/hs info document_id
```

* Lastly you are also able to download documents using a query string:
```bash
$ bin/hs download_from_query complete:true -l 100
```
 * To download all documents from a heavily used account you would need to use the flags:
   * -p, --page: Page number
   * -l, --limit: Limit items on page (Default: 20, Max: 100)

License
-------
This project is free software, and may be redistributed under the terms specified in the MIT-LICENSE file.
