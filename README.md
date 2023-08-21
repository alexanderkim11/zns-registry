# Welcome to Zexe Name Service (ZNS)

Zexe Name Service is a namespace provider and resolver for Aleo.  Similar to DNS for Web2 or ENS for Ethereum, he function of ZNS is to map human-readable names like ‘alex.zexe’ to machine-readable identifiers such as Aleo addresses, and other metadata.  

The biggest benefit of operating on the Aleo platform is the ability to create domains publicly AND privately through the power of zk-SNARKS.  By combining the power of zero-knowledge proofs with the a namespace system, ZNS enhances the user-friendliness for dApps on the network while maintaining the underlying security and privacy of Aleo.

## How to Use
### Official Site
[zexe.domains](https://zexe.domains)
### Alternatives
Additionally, you can register domain names via the snarkos command line or through [aleo.tools](https://aleo.tools)

## Deeds
Deeds are the backbone of the name registration component.  Deeds are records of ownership over a given domain, and are accordingly of the Record type in Leo.  Deeds are initially produced on both public and private domain creations and serve as a way to proof of ownership even if a given domain's information is not stored on-chain.

The following fields are present in a Deed:
   1. `private owner : address`: The owner of this Deed
      
   3. `private tld : u128`: The top level domain extension of this domain, encoded as an unsigned 128-bit integer.  Currently only .zexe is an accepted tld
      
   5. `private name : u128`: The domain name, encoded as an unsigned 128-bit integer
      
   7. `private subname : u128`: The subdomain name, encoded as an unsigned 128-bit integer
      
   9. `private registrar_name : u128`: The name of the .aleo program that serves as this domain's registrar, encoded as an unsigned 128-bit integer
       
   11. `private resolver_name : u128`: The name of the .aleo program that serves as this domain's resolver, encoded as an unsigned 128-bit integer
       
   13. `private data : field`: Additional hash data, not currently used



## Additional Structures and Mappings
   ### domainName
   A structure to help organize the code and make things more clear

   **Fields:**
      
   1. `tld : u128`: The top level domain extension of this domain, encoded as an unsigned 128-bit integer.  Currently only .zexe is an accepted top-level domain.
      
   3. `name : u128`: The domain name, encoded as an unsigned 128-bit integer
      
   5. `subname : u128`: The subdomain name, encoded as an unsigned 128-bit integer

   
   ### Domain
   A structure to help organize the code and make things more clear

   **Fields:**
   
   1. `current owner : address`: The owner of this Domain
      
   3. `name : domainName`: The domain name, wrapped inside a domainName struct (see above)

   4. `registrar: u128`: The name of the .aleo program that serves as this domain's registrar, encoded as an unsigned 128-bit integer

   4. `resolver: u128`: The name of the .aleo program that serves as this domain's resolver, encoded as an unsigned 128-bit integer
      
   6. `owner_hidden : bool`: Whether this domain is currently set to public or private

## Main Functions & Transitions

   1. `validate_name`: Validates a domain name. Only allow 0-9,a-z,- and _ characters.
   2. `register`: Registers a new private domain name. This transaction support register a domain for another receiver.
   3. `register_sub`: Registers a new private subdomain. The parent domain must be registered first and must be private domain.
   4. `register_sub_public`: Registers a new private subdomain. The parent domain must be a public domain and owned by the caller.
   5. `transfer_private`: Transfers the ownership of a private domain name to another address.
   6. `transfer_public`: Transfers the ownership of a public domain name to another address.
   7. `conver_private_to_public`: Converts a private domain to a public domain.
   8. `conver_public_to_private`: Converts a public domain to a private domain.
   9. `set_primary_name`: Sets the primary name of an address. The domain must be a public domain and owned by the caller.
   10. `unset_primary_name`: Unsets the primary name of an address.
   11. `set_resolver`: Sets the resolver for a domain name and category. The domain must be a public domain and owned by the caller.
   12. `unset_resolver`: Unsets the resolver for a domain name and category.


## Challenges

## Future Work
