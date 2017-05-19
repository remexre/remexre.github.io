# Monto Version 3 Specification Draft

## Abstract

This specification describes an improved iteration of the Monto protocol
for Disintegrated Development Environments ([\[MONTO\]](#monto)). These
improvements allow for simpler implementations for Clients. They also make
it feasible to have multiple Clients sharing a single Service.

## 1. Conventions and Terminology

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT",
"SHOULD", "SHOULD NOT", "RECOMMENDED",  "MAY", and "OPTIONAL" in this
document are to be interpreted as described in RFC 2119.

Other terms used in this specification are as follows.

Client
: An IDE, text editor, or other software directly controlled by the end
user.

Broker
: A per-user piece of software that manages communication between Clients
and Services.

Service
: A piece of software that receives Products from a Broker, and uses them
to produce other Products in response.

Message
: A single JSON value sent as an HTTP request or response.

Product
: Structured data sent between Clients, Brokers, and Services.

Client Protocol
: The protocol used to communicate between Clients and Brokers.

Service Protocol
: The protocol used to communicate between Brokers and Services.

Monto Protocols
: The Client Protocol and Service Protocol.

## 2. Introduction

Monto makes it easy to interface the information provided by a language's
compiler with various editors, without the compiler developer needing to
implement language support for each editor. Unfortunately, the native APIs
of various popular editors vary widely with respect to how well they
support the features required by Monto, namely the ability to bind to
[ZeroMQ](http://zeromq.org/) and the ability to perform actions with an
extremely high degree of asynchronicity.

This document suggests changes to the Monto Protocols which are focused on
removing the ZeroMQ requirement and lessening the requirement for
asynchronous processing of events. As these changes are not backwards
compatible with existing Clients and Services, these changes are
collectively known as Monto Version 3.

## 3. Protocol Overview

The Monto Protocols are built on top of HTTP/2 ([\[RFC7540\]](#rfc7540)),
with each request being a POST request to a special Monto endpoint. Both
request and response bodies are JSON ([\[RFC7159\]](#rfc7159)). This
allows for the reuse of the many technologies that are capable of
debugging this relatively common protocol combination, such as
[mitmproxy](https://mitmproxy.org/),
[Postman](https://www.getpostman.com/), and others. Furthermore, almost
every mainstream programming language supports HTTP and JSON, meaning the
wide variety of client programming languages (e.g. CoffeeScript, Emacs
Lisp, Java, Python, etc.) can all interoperate with it.

Both the Client Protocol and Service Protocol are versioned according to
Semantic Versioning ([\[SEMVER\]](#semver)). This document describes
Client Protocol version 3.0.0 and Service Protocol version 3.0.0.

### 3.1. The Client Protocol

Upon initiating a connection to a Broker, a Client MUST attempt to use
an HTTP/2 connection if the Client supports HTTP/2. If the Client does
not, it SHALL use the same protocol, but over HTTP/1.1 instead. If
a Client is using HTTP/1.1, it MAY open multiple connections to the server
in order to have multiple requests "in flight" at the same time.

After the HTTP connection is established, the Client SHALL make a POST
request to the `/monto/version` path, with
a [`ClientVersion`](#411-clientversion) message as the body. The Broker
SHALL check that it is compatible with the client. The Broker SHALL
respond with a [`BrokerVersion`](#421-brokerversion) message. If the
Broker is compatible with the client, this response SHALL have an HTTP
Status of 200. If the Broker and Client are not compatible, the response
SHALL instead have an HTTP status of 409. The Client SHALL check that it
is compatible with the Broker. If the Client and Broker are not
compatible, the Client SHOULD inform the user.

Compatibility between versions of the Client Protocol SHALL BE determined
using the Semantic Versioning rules. Additionally, a Client MAY reject
a Broker that is known to not follow this specification correctly, and
vice versa.

TODO

### 3.2. The Service Protocol

TODO

## 4. Messages

Messages are documented with [JSON Schema](http://json-schema.org/).

### 4.1. Client Messages

#### 4.1.1. `ClientVersion`

##### 4.1.1.1. Schema

```json
{
	"$schema": "http://json-schema.org/draft-04/schema#",
	"title": "ClientVersion",
	"type": "object",
	"properties": {
		"monto": {
			"type": "object",
			"properties": {
				"major": { "type": "integer" },
				"minor": { "type": "integer" },
				"patch": { "type": "integer" }
			},
			"additionalProperties": false,
			"required": ["major", "minor", "patch"]
		},
		"client": {
			"type": "object",
			"properties": {
				"name": { "type": "string" },
				"vendor": { "type": "string" },
				"major": { "type": "integer" },
				"minor": { "type": "integer" },
				"patch": { "type": "integer" }
			},
			"additionalProperties": false,
			"required": ["name", "major", "minor", "patch"]
		}
	},
	"additionalProperties": false,
	"required": ["monto"]
}
```

##### 4.1.1.2. Example

```json
{
	"monto": {
		"major": 3,
		"minor": 0,
		"patch": 0
	},
	"client": {
		"name": "Foo Client",
		"vendor": "ACME Inc.",
		"major": 0,
		"minor": 1,
		"patch": 0
	}
}
```

### 4.2. Broker Messages

#### 4.2.1. `BrokerVersion`

##### 4.2.1.1. Schema

```json
{
	"$schema": "http://json-schema.org/draft-04/schema#",
	"title": "ClientVersion",
	"type": "object",
	"properties": {
		"monto": {
			"type": "object",
			"properties": {
				"major": { "type": "integer" },
				"minor": { "type": "integer" },
				"patch": { "type": "integer" }
			},
			"additionalProperties": false,
			"required": ["major", "minor", "patch"]
		},
		"broker": {
			"type": "object",
			"properties": {
				"name": { "type": "string" },
				"vendor": { "type": "string" },
				"major": { "type": "integer" },
				"minor": { "type": "integer" },
				"patch": { "type": "integer" }
			},
			"additionalProperties": false,
			"required": ["name", "major", "minor", "patch"]
		}
	},
	"additionalProperties": false,
	"required": ["monto"]
}
```

##### 4.2.1.2. Example

```json
{
	"monto": {
		"major": 3,
		"minor": 0,
		"patch": 0
	},
	"broker": {
		"name": "Foo Broker",
		"vendor": "ACME Inc.",
		"major": 0,
		"minor": 1,
		"patch": 0
	}
}
```

# 4.3. Service Messages

TODO

## 5. Products

TODO

## 6. Security Considerations

### 6.1. Remote Access To Local Files

The Broker sends arbitrary files to Services, which may be running on
a different machine. A malicious service could therefore request
a sensitive file (for example, `~/.ssh/id_rsa`) 

### 6.2. Encrypted Transport

HTTP/2 optionally supports TLS encryption. Most HTTP/2 implementations
require encryption, so Clients, Brokers, and Services MAY support TLS
encryption. Due to the relative difficulty of obtaining a TLS certificate
for a local service, Clients MUST support connecting to a Broker that does
not support TLS.

## 7. Further Work

### 7.1. MessagePack

A speed boost could potentially be gained by moving to
[MessagePack](http://msgpack.org/) or a similar format. This could be
added in a backwards-compatible way by using the existing Content-Type
negotiation mechanisms in HTTP.

### 7.2. Asynchronous Communication

Re-adding support for asynchronous communication between Clients and
Brokers on an opt-in basis would be a desirable goal. This could be
implemented either by polling, which is relatively efficient in HTTP/2, or
with a chunked response in HTTP/1.1.

## 8. References

### 8.1. Normative References

[](){:name="monto"}
[MONTO]: Keidel, S., Pfeiffer, W., and S. Erdweg., "The IDE Portability
Problem and Its Solution in Monto",
[doi:10.1145/2997364.2997368](http://dx.doi.org/10.1145/2997364.2997368),
November 2016.

[](){:name="rfc2119"}
[RFC2119]: Bradner, S., "Key words for use in RFCs to Indicate Requirement
Levels", [BCP 14](https://tools.ietf.org/html/bcp14), [RFC
2119](https://tools.ietf.org/html/rfc2119), March 1997.

[](){:name="rfc7159"}
[RFC7159]: Bray, T., "The JavaScript Object Notation (JSON) Data
Interchange Format", [RFC 7159](https://tools.ietf.org/html/rfc7159),
March 2014.

[](){:name="rfc7540"}
[RFC7540]: Belshe, M., Peon, R., and M. Thomson, Ed., "Hypertext Transfer
Protocol Version 2 (HTTP/2)", [RFC
7540](https://tools.ietf.org/html/rfc7540), May 2015.

[](){:name="semver"}
[SEMVER]: "Semantic Versioning 2.0.0",
[http://semver.org/spec/v2.0.0.html]().
