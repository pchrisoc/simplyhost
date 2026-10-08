---
title: Intro
nav_order: 2
---

# Intro

## Who am I?
- My name is Patrick O'Connor and I studied [Electrical Engineering and Computer Science at University of California, Berkeley](https://eecs.berkeley.edu/).
- At UC Berkeley, I learned how to use [Git](https://github.com), [SSH](https://en.wikipedia.org/wiki/Secure_Shell), and various programming languages.
- It was my curiosity that led me to discover [Docker](https://docker.com), [Cloudflare](https://cloudflare.com), and subsequently [self-hosting](https://en.wikipedia.org/wiki/Self-hosting_(network)).
- My first self-hosted application was [Vaultwarden](https://github.com/dani-garcia/vaultwarden) running on a [RaspberryPi](https://www.raspberrypi.com/) (shout out to Uncle Mike if you are reading this, best present ever).
- Now I have 4 [ProxMox Virtual Environment](https://proxmox.xom) Nodes running [Linux containers](https://en.wikipedia.org/wiki/LXC) (LXCs) and [Virtual Machines](https://en.wikipedia.org/wiki/Virtual_machine) (VMs) that run close to a hundred various [Docker containers](https://www.docker.com/resources/what-container/).

## What is self-hosting (in layman terms)?
- [You have a client, and you have a server.](https://en.wikipedia.org/wiki/Client%E2%80%93server_model) ![Source: Wikipedia](https://upload.wikimedia.org/wikipedia/commons/c/c9/Client-server-model.svg?utm_source=en.wikipedia.org&utm_campaign=index&utm_content=original)
- Imagine the physical component of a server as a computer that is always running, and the client as your device, talking to that server. For example, your email app (e.g. Outlook, Mail, Gmail) is a client for viewing the data (e.g. your username, password, and emails) stored on that server.
- Self-hosting is taking your own hardware, and hosting your own applications. You are creating your very own server in order to store and access that data with another client (device). My favorite container is Vaultwarden, and it stores all of my passwords on my server. When I update on one device, it sends to the server, and all devices will subsequently update as well. 

## How do I reach my server?
- Your server exposes applications through [ports](https://en.wikipedia.org/wiki/Port_(computer_networking)).
- These ports can be accessed when added to the end of that devices IP address.
- The [Internet Protocol Address](https://en.wikipedia.org/wiki/IP_address) (IP address) is assigned to every connection of a device to the network.
- There are [private network](https://en.wikipedia.org/wiki/Private_network) addresses (e.g. 192.168.1.X, 10.0.0.X) and public network addresses.
- Private IP addresses are assigned by your [router](https://en.wikipedia.org/wiki/Router_(computing)) and accessible only on your local network (under the same roof).
- Public IP addresses are assigned by your [Internet Service Provider](https://en.wikipedia.org/wiki/Internet_service_provider) (ISP) (e.g. AT&T) and are accessible to everyone from anywhere. You will need to [forward a port](https://en.wikipedia.org/wiki/Port_forwarding) from your router in order to access via public IP address, but due to security concerns, it is best to use a service like Tailscale that allows remote connections through their servers. You can also use a [Virtual Private Server](https://en.wikipedia.org/wiki/Virtual_private_server) (VPS) hosted by someone else!
- Also, your Wi-Fi is not your [internet](https://textbook.cs168.io/intro/intro.html)! They are two very different things. Wi-Fi is a family of network protocols that allow connection to your network over radio waves. 
- In conclusion, your applications on your private, local network will look like: 'http://192.168.1.50:8080' (http is unencrypted, https is [encrypted](https://en.wikipedia.org/wiki/Encryption)).

## Why should you self-host?
- While there are numerous reasons to self-host, I have found the challenge of learning something new, the retention of my personal data, and the convenience that managing your own software provides as the core reasons I have continued my journey.
- Most of everything on this site is [open-source](https://en.wikipedia.org/wiki/Open_source) with some exceptions (e.g. [Tailscale](https://tailscale.com/)). There is usually an open-source implementation for every closed-source one (e.g. Firefox vs. Chrome), And I like to argue that the open-source option is usually better.
- A vast amount of containers (conceptualize this as your various "apps") can run sufficiently on hardware you already have (e.g. old laptop, old desktop, mobile devices).
- Self-hosting *can* save you money (especially on stupid subscriptions), but with the [increasing computer parts](https://pcpartpicker.com/trends/) and many ways to add to your self-hosting journey that cost money (e.g. VPS and domain subscriptions) it can get to a point where it is a hobby, and hobbies have budgets.

