# Welcome to Zexe Name Service (ZNS)

Zexe Name Service is a namespace provider and resolver for Aleo.  Similar to DNS for Web2 or ENS for Ethereum, he function of ZNS is to map human-readable names like ‘alex.zexe’ to machine-readable identifiers such as Aleo addresses, and other metadata.  

The biggest benefit of operating on the Aleo platform is the ability to create domains publicly AND privately through the power of zk-SNARKS.  By combining the power of zero-knowledge proofs with the a namespace system, ZNS enhances the user-friendliness for dApps on the network while maintaining the underlying security and privacy of Aleo.


## How to Use
### Official Site:
[zexe.domains](https://zexe.domains)


### Alternatives:
Additionally, you can register domain names via the snarkos command line or through [aleo.tools](https://aleo.tools)


## Deeds
Deeds are the backbone of the name registration component.  Deeds are records of ownership over a given domain, and are accordingly of the Record type in Leo.  Deeds are initially produced on both public and private domain creations and serve as a way to proof of ownership even if a given domain's information is not stored on-chain.
Many functions in zns_registry.aleo consume Deeds as a part of verifying ownership, producing new Deed records with the same information upon success.

The following fields are present in a Deed:
   1. `private owner : address`: The owner of this Deed
      
   3. `private tld : u128`: The top level domain extension of this domain, encoded as an unsigned 128-bit integer.  Currently only .zexe is an accepted tld
      
   5. `private name : u128`: The domain name, encoded as an unsigned 128-bit integer
      
   7. `private subname : u128`: The subdomain name, encoded as an unsigned 128-bit integer
      
   9. `private registrar_name : u128`: The name of the .aleo program that serves as this domain's registrar, encoded as an unsigned 128-bit integer
       
   11. `private resolver_name : u128`: The name of the .aleo program that serves as this domain's resolver, encoded as an unsigned 128-bit integer
       
   13. `private data : field`: Additional hash data, not currently used
       
&nbsp;

## Operator Certificates
Operator certificates power the subdomain creation process.  Only the owner of a domain can issue operator certificates to other users.  A valid operator certificate allows a user to create subdomains for a given upper domain.

For example, if Alex owns `alex.zexe` and issues an operator certificate to Bob, then Bob will be able to create subdomains such as `bob.alex.zexe` or `app.alex.zexe`.

The following fields are present in an operatorCert:
   1. `private owner : address`: The owner of this certificate
      
   3. `private supervisor : address`: The issuer of this certificate; this can only be the owner of the domain for now
      
   4. `private tld : u128`: The top level domain extension of this domain, encoded as an unsigned 128-bit integer.  Currently only .zexe is an accepted tld
      
   5. `private dname : u128`: The domain name, encoded as an unsigned 128-bit integer
      
       
&nbsp;



## Additional Structures and Mappings
   ### domainName:
   A structure to help organize the code and make things more clear

   **Fields:**
      
   1. `tld : u128`: The top level domain extension of this domain, encoded as an unsigned 128-bit integer.  Currently only .zexe is an accepted top-level domain.
      
   3. `name : u128`: The domain name, encoded as an unsigned 128-bit integer
      
   5. `subname : u128`: The subdomain name, encoded as an unsigned 128-bit integer

&nbsp;

   
   ### Domain:
   A structure to help organize the code and make things more clear

   **Fields:**
   
   1. `current owner : address`: The owner of this Domain
      
   3. `name : domainName`: The domain name, wrapped inside a domainName struct (see above)

   4. `registrar: u128`: The name of the .aleo program that serves as this domain's registrar, encoded as an unsigned 128-bit integer

   4. `resolver: u128`: The name of the .aleo program that serves as this domain's resolver, encoded as an unsigned 128-bit integer
      
   6. `owner_hidden : bool`: Whether this domain is currently set to public or private

&nbsp;

   ### domain_taken:
   A mapping from a domainName struct to a bool on whether or not that domain name has been registered

   ### domains:
   A mapping from a domainName struct to a full Domain struct

   ### primary_name:
   A mapping from addresses to a primary domainName
   
&nbsp;

## Main Functions

   ### create_public()
   Register a new name publicly, storing requisite information on-chain and displaying unencrypted address.

   **Parameters:**
      
   1. `public encoded_domain_name : domainName`: The domain name to be registered, formatted as a domainName struct
      
   3. `public registrar_ : u128`: The name of the .aleo program to serve as this domain's registrar, encoded as an unsigned 128-bit integer
      
   5. `public resolver_ : u128`: The name of the .aleo program to serve as this domain's resolver, encoded as an unsigned 128-bit integer

   **Return:**
   
   1. `new_deed : Deed`: Upon success, return Deed containing all of the information for the newly created domain.

      &nbsp;
   
   ### create_private()
   Register a new name private, NOT storing requisite information on-chain and only displaying encrypted address.

   **Parameters:**
      
   1. `public encoded_domain_name : domainName`: The domain name to be registered, formatted as a domainName struct
      
   3. `private registrar_ : u128`: The name of the .aleo program to serve as this domain's registrar, encoded as an unsigned 128-bit integer
      
   5. `private resolver_ : u128`: The name of the .aleo program to serve as this domain's resolver, encoded as an unsigned 128-bit integer

   **Return:**
   
   1. `new_deed : Deed`: Upon success, return Deed containing all of the information for the newly created domain.
      

      &nbsp;
      
   ### create_subdomain_public()
   Register a new subname publicly, storing requisite information on-chain and displaying unencrypted address.

   **Parameters:**
      
   1. `private permission : operatorCert`: An operatorCert verifying that the caller is allowed to create subdomains for the provided domain
      
   3. `public subname_ : u128`: The subname to be registered, encoded as an unsigned 128-bit integer
      
   3. `public registrar_ : u128`: The name of the .aleo program to serve as this subdomain's registrar, encoded as an unsigned 128-bit integer
      
   5. `public resolver_ : u128`: The name of the .aleo program to serve as this subdomain's resolver, encoded as an unsigned 128-bit integer

   **Return:**
   
   1. `new_deed : Deed`: Upon success, return Deed containing all of the information for the newly created subdomain.
      
   3. `new_cert : operatorCert`: Upon success, return operatorCert containing all of the same information as before.

      &nbsp;

   ### create_subdomain_private()
   Register a new subname private, NOT storing requisite information on-chain and only displaying encrypted address.

   **Parameters:**
      
   1. `private permission : operatorCert`: An operatorCert verifying that the caller is allowed to create subdomains for the provided domain
      
   3. `private subname_ : u128`: The subname to be registered, encoded as an unsigned 128-bit integer
      
   3. `private registrar_ : u128`: The name of the .aleo program to serve as this subdomain's registrar, encoded as an unsigned 128-bit integer
      
   5. `private resolver_ : u128`: The name of the .aleo program to serve as this subdomain's resolver, encoded as an unsigned 128-bit integer

   **Return:**
   
   1. `new_deed : Deed`: Upon success, return Deed containing all of the information for the newly created subdomain.
      
   3. `new_cert : operatorCert`: Upon success, return operatorCert containing all of the same information as before.


      &nbsp;

   
   ### update_public()
   Update the registrar and/or resolver for a given domain, converting domain to public in the process

   **Parameters:**
      
   1. `public registrar_ : u128`: The name of the .aleo program to set as this domain's registrar, encoded as an unsigned 128-bit integer
      
   5. `public resolver_ : u128`: The name of the .aleo program to set as this domain's resolver, encoded as an unsigned 128-bit integer

   5. `private deed : Deed`: A deed record proving ownership of the domain that will be updated

   **Return:**
   
   1. `new_deed : Deed`: Upon success, return Deed containing all of the information for the updated domain.


      &nbsp;
   
   ### update_private()
   Update the registrar and/or resolver for a given domain, converting domain to private in the process

   **Parameters:**
      
   1. `private registrar_ : u128`: The name of the .aleo program to set as this domain's registrar, encoded as an unsigned 128-bit integer
      
   5. `private resolver_ : u128`: The name of the .aleo program to set as this domain's resolver, encoded as an unsigned 128-bit integer

   5. `private deed : Deed`: A deed record proving ownership of the domain that will be updated

   **Return:**
   
   1. `new_deed : Deed`: Upon success, return Deed containing all of the information for the updated domain.

      &nbsp;
   
   ### set_Primary()
   Sets the provided domain as the primary name for the caller/owner

   **Parameters:**

   1. `private deed : Deed`: A deed recording proving ownership of the domain that will be set to primary

   **Return:**
   
   1. `new_deed : Deed`: Upon success, return Deed containing the same domain information as prior.

      &nbsp;
   
   ### transfer_public_to_public()
   Transfers a public domain to another owner, maintaining public status.

   **Parameters:**
   
   1. `public new_owner : address`: The address of the new owner
      
   3. `private deed : Deed`: A deed record proving ownership of the domain that will be transferred

   **Return:**
   
   1. `new_deed : Deed`: Upon success, return Deed record for the new owner containing the domain information.

      &nbsp;
   
   ### transfer_public_to_private()
   Transfers a public domain to another owner, converting to private status.

   **Parameters:**
   
   1. `public new_owner : address`: The address of the new owner
      
   3. `private deed : Deed`: A deed record proving ownership of the domain that will be transferred

   **Return:**
   
   1. `new_deed : Deed`: Upon success, return Deed record for the new owner containing the domain information.

      &nbsp;
   
   ### transfer_private_to_public()
   Transfers a private domain to another owner, converting to public status.

   **Parameters:**
   
   1. `private new_owner : address`: The address of the new owner
      
   3. `private deed : Deed`: A deed record proving ownership of the domain that will be transferred

   **Return:**
   
   1. `new_deed : Deed`: Upon success, return Deed record for the new owner containing the domain information.

      &nbsp;
   
   ### transfer_private_to_private()
   Transfers a private domain to another owner, maintaining private status.

   **Parameters:**
   
   1. `private new_owner : address`: The address of the new owner
      
   3. `private deed : Deed`: A deed record proving ownership of the domain that will be transferred

   **Return:**
   
   1. `new_deed : Deed`: Upon success, return Deed record for the new owner containing the domain information.

&nbsp;


&nbsp;

## Challenges

&nbsp;

## Future Work
