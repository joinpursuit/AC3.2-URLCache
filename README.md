### AC3.2-URLCache
---

### Objective
To understand how the use of URLCache can improve the performance and efficiency of our applications.

### Readings

1. [NSURLCache - NSHipster](http://nshipster.com/nsurlcache/)
2. [URLCache - Apple Doc](https://developer.apple.com/reference/foundation/urlcache)
3. [HTTP Headers](https://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html)
4. [HTTP Caching](http://www.w3.org/Protocols/rfc2616/rfc2616-sec13.html#sec13)
5. [Apple's URL Caching Guide](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/URLLoadingSystem/URLLoadingSystem.html#//apple_ref/doc/uid/10000165-BCICJDHA)

#### Vocabulary

1. **HTTP** - *HyperText Transfer Protocol. HTTP is the underlying protocol used by the World Wide Web and this protocol defines how messages are formatted and transmitted, and what actions Web servers and browsers should take in response to various commands.*

>For example, when you enter a URL in your browser, this actually sends an HTTP command to the Web server directing it to fetch and transmit the requested Web page. The other main standard that controls how the World Wide Web works is HTML, which covers how Web pages are formatted and displayed.

2. **HTTP Status Codes** (i.e. 200, 404) - *In HTTP/1.0 and since, the first line of the HTTP response is called the status line and includes a numeric status code (such as "404") and a textual reason phrase (such as "Not Found")*

> HTTP status code is primarily divided into five groups for better explanation of request and responses between client and server as named:
>  * Informational 1XX
>  * Successful 2XX
>  * Redirection 3XX
>  * Client Error 4XX
>  * Server Error 5XX

3. **Cache** - *A hardware or software component that stores data so future requests for that data can be served faster. The data stored in a cache might be the result of an earlier computation, or the duplicate of data stored elsewhere*

4. **Client** - *The client side of a client-server architecture. Typically, a client is an application that runs on a personal computer or workstation and relies on a server to perform some operations. The communication between client and server takes place using the Hypertext Transfer Protocol (HTTP)*

>In the real world, businesses have clients. In the computer world, servers have clients. The "client-server" architecture is common in both local and wide area networks. For example, if an office has a server that stores the company's database on it, the other computers in the office that can access the datbase are "clients" of the server.
>
>On a larger scale, when you access your e-mail from a mail server on the Internet, your computer acts as the client that connects to the mail server. The term "client software" is used to refer to the software that acts as the interface between the client computer and the server. For example, if you use Microsoft Outlook to check your e-mail, Outlook is your "e-mail client software" that allows you to send and receive messages from the server.

5. **Server** - *A web server is a computer system that processes requests via HTTP, the basic network protocol used to distribute information on the World Wide Web. The term can refer to the entire system, or specifically to the software that accepts and supervises the HTTP requests.*

6. **Header** - *HTTP headers are the code that transfers data between a Web server and a browser. That data is in the form of a text record that a user's browser sends to a Web server containing the details of what the browser wants and will accept back from the server. The request header also contains the type, version and capabilities of the browser that is making the request so that server returns compatible data. Upon receipt of the request header, the server will return an HTTP response header to the client that is attached to the file(s) being sent.*
---

### 1. Why Caching?

We're coming at this subject from a higher level than we've usually been doing. So far, we've mainly focused
on getting specific stuff done and having a good deal of, if not complete, control over what we're doing.
Here, we're exploring how an external protocol (HTTP) on the server we're interacting with will affect our 
app's behavior. We'll also be looking at ways to override this behavior. 

>"Network caching reduces the number of requests that need to be made to the server, and improves the experience of using an application offline or under slow network conditions.
>
>When a request has finished loading its response from the server, a cached response will be saved locally. The next time the same request is made, the locally-cached response will be returned immediately, without connecting to the server. NSURLCache returns the cached response automatically and transparently."
>
>~ NSHipster

The take away from this is a different kind of tool in your tool box. You will be able to advise
the teams you're on of what caching can provide, and how to figure it out based on the app requirements.

Our most immediate opportunity to play more than a reactive role in the process will be when we 
work on a cross-cohort project with the 3.1 (Full Stack Web) class, either during regular class time, 
at a hackathon or both.

### 2. Cache Use Semantics for the HTTP Protocol

> From [Apple's Session Programming Guide](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/URLLoadingSystem/Concepts/CachePolicies.html)
> The most complicated cache use situation is when a request uses the HTTP protocol and has set the cache policy to 
> NSURLRequestUseProtocolCachePolicy.
> 
> If an NSCachedURLResponse does not exist for the request, then the URL loading system fetches the data from the 
> originating source.
> 
> If a cached response exists for the request, the URL loading system checks the response to determine if it 
> specifies that the contents must be revalidated.
> 
> If the contents must be revalidated, the URL loading system makes a HEAD request to the originating source
> to see if the  resource has changed. If it has not changed, then the URL loading system returns the cached
> response. If it has changed, the URL loading system fetches the data from the originating source.
> 
> If the cached response doesn’t specify that the contents must be revalidated, the URL loading system 
> examines the maximum  age or expiration specified in the cached response. If the cached response is 
> recent enough, then the URL loading system  returns the cached response. If the response is stale, 
> the URL loading system makes a HEAD request to the originating  source to determine whether the 
> resource has changed. If so, the URL loading system fetches the resource from the  originating source.
> Otherwise, it returned the cached response.

### 3. Testing techniques

* **Postman**
    
    Use Postman or any browser-based diagnostic tool that allows you to run HTTP requests
    and inspect the headers. Look for ```Cache-Control``` and ```Last-Modified``` headers.

* **Delete the app**

    This guarantees that all cached data is deleted and is an important use/edge case: what is 
    the initial behavior of the app. Can also serve as a quick and dirty sanity check when 
    previously unknown or unconsidered caching is suspected.

* **Diagnostics in the code**

    As with Postman, look for ```Cache-Control``` and ```Last-Modified``` headers in your code.

    ```swift
    if let cachedResponse = URLCache.shared.cachedResponse(for: request)?.response as? HTTPURLResponse {
        print("URL \(myURL) FOUND IN CACHE")
        if let cacheControl = cachedResponse.allHeaderFields["Cache-Control"] as? String {
            print("Cache-Control: \(cacheControl)")
        }
        
        // this will have elicit a 304 status code
        if let lastModified = cachedResponse.allHeaderFields["Last-Modified"] as? String {
            print("Last-Modified: \(lastModified)")
            
            request.setValue(lastModified, forHTTPHeaderField: "If-Modified-Since")
        }
    }
    ```

* **Turn the network off and on**
    
    This is a good way to see what's currently cached and to test other cache policies that
    don't load from cache.

* **Network Traffic / Packet Sniffers**
    * [Charles Proxy](https://www.charlesproxy.com)
    You have to jump through some extra hoops to get SSL to work.
    https://www.charlesproxy.com/documentation/faqs/ssl-connections-from-within-iphone-applications/

---

## Exercise

1. Using Postman, let's go through previous API projects and look for ```Cache-Control``` and
 ```Last-Modified``` headers in JSON and image requests. Put the results in [this spreadsheet](https://docs.google.com/spreadsheets/d/1Na7V3h6LFg-n4HWyp7JzGTiCnrQu1cQ15-8ebgz-rUA/edit#gid=0).

2. Experiment with changing the caching behavior within the app.



