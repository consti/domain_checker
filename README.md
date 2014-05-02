## Readme

Check domains based on a list of words AND their synonyms.

I'm using the [RoboWhois API](https://www.robowhois.com/) and [Wortschatz API](http://wortschatz.informatik.uni-leipzig.de) of the University of Leipzig.

* Store your (RoboWhois) ```API_KEY=XXXXXXXX``` in ```.env```.
* Set your list of  (german) ```WORDS```. Make sure to correctly spell and capitalize them.
* Set your list of ```TLDS```
* Run ```bundle && ./domain_checker.rb```
* Look at the pretty output. On iTerm2: [CMD]+Click to open URLs to buy domains.
* Check ```./available.txt``` for domains that are free
* Buy that domain!

Checkout [that screen recording](http://showterm.io/1e9da87d722ddf4b4079e) to see it in action!

![DomainChecker in Action](http://i.imgur.com/gwBvr8C.png)

### License

The MIT License (MIT)

Copyright (c) 2014 Constantin Hofstetter

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
