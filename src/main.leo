//TODO: Add check to make sure names are formattted correctly
program zns_registry_v1_3.aleo {

    mapping domain_taken: domainName => bool;
    mapping domains: domainName => Domain;
    mapping primary_name: address => domainName;


    //Elements are dot(.) separated components of domain Name, encoded as ascii and concatenated with zero-padding
    //0u128 is null-character(end of string)
    struct domainName{
        tld : u128,
        name : u128,
        subname : u128,
    }

    struct Domain {
        current_owner : address,
        name : domainName,
        registrar: u128,
        resolver: u128,
        owner_hidden : bool,
    }

    record Deed {
        private owner: address,
        private tld : u128,
        private name : u128,
        private subname : u128,
        private registrar_name : u128,
        private resolver_name : u128,
        private data : field,
    }

    //Whether or not a user has permission to operate within a given domain
    record operatorCert {
        private owner : address,
        private supervisor : address,
        private tld : u128,
        private dname : u128,
    }


    /* Helper Functions */

    transition domain_taken_check(tld_:u128, name_:u128, subname_:u128){
        return then finalize(tld_, name_, subname_);
    }
    finalize domain_taken_check(tld_:u128, name_:u128, subname_:u128){
        let new_name : domainName = domainName{
            tld : tld_,
            name : name_,
            subname : subname_,
        };
        assert(domain_taken.get_or_use(new_name, false) == false);
    }


    function return_null_domain(hashed_caller:address) -> Domain{
        let null_programName : u128 = 0u128;
        let null_domainName : domainName = domainName{
            tld : 0u128,
            name : 0u128,
            subname : 0u128,
        };
        let null_domain : Domain = Domain {
            current_owner : hashed_caller,
            name : null_domainName,
            registrar: null_programName,
            resolver: null_programName,
            owner_hidden : true,
        };
        return null_domain;
    }


    function format_domain_name(tld_:u128, name_:u128, subname_:u128) -> domainName{
        let new_name : domainName = domainName{
            tld : tld_,
            name : name_,
            subname : subname_,
        };
        return new_name;
    }







    /* Registrar Operator Cert Methods*/
    transition request_operator_cert(private operator : address, private tld_: u128, private name_ : u128) -> operatorCert{
        let temp_name : domainName = domainName{
            tld : tld_,
            name : name_,
            subname : 0u128,
        };
        let new_cert : operatorCert = operatorCert{
            owner : operator,
            supervisor : self.caller,
            tld : tld_,
            dname : name_
        };
        return new_cert then finalize(self.caller, temp_name);
    }
    finalize request_operator_cert(public caller : address , public domain_name : domainName){
        let stored_domain : Domain = domains.get(domain_name);
        assert((stored_domain.owner_hidden ? stored_domain.current_owner == BHP1024::hash_to_address(caller) : stored_domain.current_owner == caller) == true);
    }











    /* Create a new Domain on the Aleo Name Service */

    transition create_domain_public(public encoded_domain_name: domainName, public registrar_: u128, public resolver_: u128) -> Deed {
        assert (encoded_domain_name.tld == 6837765u128); //Only .zexe extension allowed for now
        assert (encoded_domain_name.name != 0u128); //Cannot create empty string domain name
        assert (encoded_domain_name.subname == 0u128); //Use create_subdomain_public to create subdomains
        let new_domain : Domain = Domain{
            current_owner : self.caller,
            registrar: registrar_,
            resolver: resolver_,
            name : encoded_domain_name,
            owner_hidden : false
        };
        let new_deed : Deed = Deed{
            owner: self.caller,
            tld : encoded_domain_name.tld,
            name: encoded_domain_name.name,
            subname : encoded_domain_name.subname,
            registrar_name : registrar_,
            resolver_name : resolver_,
            data : BHP1024::hash_to_field(new_domain),

        };
        return new_deed then finalize(encoded_domain_name, new_domain);
    }
    finalize create_domain_public(public encoded_domain_name: domainName, public new_domain : Domain){
        let check: bool = !(domain_taken.get_or_use(encoded_domain_name, false)); // 1u8
        assert(check == true);
        domain_taken.set(encoded_domain_name, true);
        domains.set(encoded_domain_name, new_domain);
    }


    transition create_domain_private(public encoded_domain_name: domainName, private registrar_: u128, private resolver_: u128) -> Deed {
        assert (encoded_domain_name.tld == 6837765u128); //Only .zexe extension allowed for now
        assert (encoded_domain_name.name != 0u128); //No null name
        assert (encoded_domain_name.subname == 0u128); //Use create_subdomain_public to create subdomains
        let hashed_caller : address = BHP1024::hash_to_address(self.caller);
        let new_domain : Domain = Domain{
            current_owner : hashed_caller,
            registrar: registrar_,
            resolver: resolver_,
            name : encoded_domain_name,
            //ttl: 31556926u64,
            owner_hidden : true,
        };
        let new_deed : Deed = Deed{
            owner: self.caller,
            tld : encoded_domain_name.tld,
            name: encoded_domain_name.name,
            subname : encoded_domain_name.subname,
            registrar_name : registrar_,
            resolver_name : resolver_,
            data : BHP1024::hash_to_field(new_domain),

        };
        return new_deed then finalize(encoded_domain_name, return_null_domain(hashed_caller));
    } 
    finalize create_domain_private(public encoded_domain_name : domainName, public null_domain : Domain){
        let check: bool = !(domain_taken.get_or_use(encoded_domain_name, false));
        assert(check == true);
        domain_taken.set(encoded_domain_name, true);
        domains.set(encoded_domain_name, null_domain);
    }













    /*Create subdomain functions*/

    transition create_subdomain_public(public permission : operatorCert, public subname_ : u128, public registrar_: u128, public resolver_: u128) -> (Deed, operatorCert) {
        let encoded_domain_name : domainName = domainName{
            tld : permission.tld,
            name : permission.dname,
            subname : subname_,
        };
        assert (encoded_domain_name.tld == 6837765u128); //Only .zexe extension allowed for now
        assert (encoded_domain_name.name != 0u128); //Cannot create empty string domain name
        assert (encoded_domain_name.subname != 0u128); //Cannot create null subdomain name
        assert(permission.tld == encoded_domain_name.tld);
        assert(permission.dname == encoded_domain_name.name);
        assert(registrar_ != 0u128); //check if registrar program name is malformed
        assert(resolver_ != 0u128); //check if resolver program name is malformed
        let upper_name : domainName = domainName{
            tld : permission.tld,
            name : permission.dname,
            subname : 0u128,
        };

        let new_domain : Domain = Domain{
            current_owner : self.caller,
            registrar: registrar_,
            resolver: resolver_,
            name : encoded_domain_name,
            owner_hidden : false
        };
        let new_deed : Deed = Deed{
            owner: self.caller,
            tld : encoded_domain_name.tld,
            name: encoded_domain_name.name,
            subname : encoded_domain_name.subname,
            registrar_name : registrar_,
            resolver_name : resolver_,
            data : BHP1024::hash_to_field(new_domain),

        };
        return (new_deed, permission) then finalize(encoded_domain_name, upper_name, BHP1024::hash_to_address(permission.supervisor), new_domain);
    }
    finalize create_subdomain_public(public encoded_domain_name: domainName, public upper_domain_name : domainName, public hashed_supervisor:address, public new_domain : Domain){
        let check: bool = !(domain_taken.get_or_use(encoded_domain_name, false));
        assert(check == true);
        let upper_domain : Domain = domains.get(upper_domain_name);
        let check2 : bool = (upper_domain.owner_hidden == true ? upper_domain.current_owner == hashed_supervisor : BHP1024::hash_to_address(upper_domain) == hashed_supervisor);
        assert(check2 == true);
        domain_taken.set(encoded_domain_name, true);
        domains.set(encoded_domain_name, new_domain);
    }


    transition create_subdomain_private(private permission : operatorCert, public subname_ : u128, private registrar_ : u128, private resolver_ : u128) -> (Deed, operatorCert){
        let encoded_domain_name : domainName = domainName{
            tld : permission.tld,
            name : permission.dname,
            subname : subname_,
        };
        assert (encoded_domain_name.tld == 6837765u128); //Only .zexe extension allowed for now
        assert (encoded_domain_name.name != 0u128); //Cannot create empty string domain name
        assert (encoded_domain_name.subname != 0u128); //Cannot create null subdomain name
        assert(permission.tld == encoded_domain_name.tld);
        assert(permission.dname == encoded_domain_name.name);
        assert(registrar_ != 0u128); //check if registrar program name is malformed
        assert(resolver_ != 0u128); //check if resolver program name is malformed
        let upper_name : domainName = domainName{
            tld : permission.tld,
            name : permission.dname,
            subname : 0u128,
        };
        let hashed_caller : address = BHP1024::hash_to_address(self.caller);
        let new_domain : Domain = Domain{
            current_owner : hashed_caller,
            registrar: registrar_,
            resolver: resolver_,
            name : encoded_domain_name,
            owner_hidden : true
        };
        let new_deed : Deed = Deed{
            owner: self.caller,
            tld : encoded_domain_name.tld,
            name: encoded_domain_name.name,
            subname : encoded_domain_name.subname,
            registrar_name : registrar_,
            resolver_name : resolver_,
            data : BHP1024::hash_to_field(new_domain),

        };
        return (new_deed, permission) then finalize(encoded_domain_name, upper_name, BHP1024::hash_to_address(permission.supervisor), return_null_domain(hashed_caller));
    } 
    finalize create_subdomain_private(public encoded_domain_name : domainName, public upper_domain_name : domainName, public hashed_supervisor:address, public null_domain : Domain){
        let check: bool = !(domain_taken.get_or_use(encoded_domain_name, false));
        assert(check == true);
        let upper_domain : Domain = domains.get(upper_domain_name);
        let check2 : bool = (upper_domain.owner_hidden == true ? upper_domain.current_owner == hashed_supervisor : BHP1024::hash_to_address(upper_domain) == hashed_supervisor);
        assert(check2 == true);
        domain_taken.set(encoded_domain_name, true);
        domains.set(encoded_domain_name, null_domain);
    }












    /* Public Setter Function */
    transition update_public(public resolver_ : u128, public registrar_ : u128, private deed : Deed) -> Deed {
        assert(deed.owner == self.caller);
        let encoded_domain_name : domainName = domainName{
            tld : deed.tld,
            name : deed.name,
            subname : deed.subname,
        };
        let update : Domain = Domain{
            current_owner : deed.owner,
            registrar: registrar_,
            resolver: resolver_,
            name: encoded_domain_name,
            owner_hidden : false,
        };
        let updated_deed : Deed = Deed{
            owner: self.caller,
            tld : encoded_domain_name.tld,
            name: encoded_domain_name.name,
            subname : encoded_domain_name.subname,
            registrar_name : registrar_,
            resolver_name : resolver_,
            data : BHP1024::hash_to_field(update),

        };
        return updated_deed then finalize(encoded_domain_name, update);
    }
    finalize update_public(public encoded_domain_name: domainName, public updated_domain : Domain){
        domains.set(encoded_domain_name, updated_domain);
    }


    /* Private Setter Function */
    //Updates domain and deed information privately and changes on-chain data to NULL fields (hidden) 

    transition update_private(private resolver_ : u128, private registrar_ : u128, private deed : Deed) -> Deed {
        assert(deed.owner == self.caller);
        let encoded_domain_name : domainName = domainName{
            tld : deed.tld,
            name : deed.name,
            subname : deed.subname,
        };
        let hashed_caller : address = BHP1024::hash_to_address(self.caller);
        let update : Domain = Domain{
            current_owner : hashed_caller,
            registrar: registrar_,
            resolver: resolver_,
            name: encoded_domain_name,
            owner_hidden : true,
        };
        let updated_deed : Deed = Deed{
            owner: deed.owner,
            tld : encoded_domain_name.tld,
            name: encoded_domain_name.name,
            subname : encoded_domain_name.subname,
            registrar_name : registrar_,
            resolver_name : resolver_,
            data : BHP1024::hash_to_field(update),

        };
        return updated_deed then finalize(encoded_domain_name, update);
    }
    finalize update_private(public encoded_domain_name: domainName, public updated_domain : Domain){
        domains.set(encoded_domain_name, updated_domain);
    }

    //Primary name setter function
    transition set_primary(private deed : Deed) -> Deed {
        assert(deed.owner == self.caller);
        let encoded_domain_name : domainName = domainName{
            tld : deed.tld,
            name : deed.name,
            subname : deed.subname,
        };
        let same_deed : Deed = Deed{
            owner: deed.owner,
            tld : encoded_domain_name.tld,
            name: encoded_domain_name.name,
            subname : encoded_domain_name.subname,
            registrar_name : deed.registrar_name,
            resolver_name : deed.resolver_name,
            data : deed.data,
        };
        return same_deed then finalize(self.caller, encoded_domain_name);
    }
    finalize set_primary(public caller : address, public encoded_domain_name : domainName){
        primary_name.set(caller, encoded_domain_name);
    }


    //Primary name setter function
    transition set_primary2(private tld_:u128, private name_:u128, private subname_:u128) -> Deed {
        let encoded_domain_name : domainName = domainName{
            tld : tld_,
            name : name_,
            subname : subname_,
        };
        return then finalize(self.caller, encoded_domain_name);
    }
    finalize set_primary2(public caller : address, public encoded_domain_name : domainName){
        let stored_domain : Domain = domains.get(encoded_domain_name);
        assert((stored_domain.owner_hidden ? stored_domain.current_owner == BHP1024::hash_to_address(caller) : stored_domain.current_owner == caller) == true);
        primary_name.set(caller, encoded_domain_name);
    }




    /* Transfer Functions */
    transition transfer_public_to_public(public new_owner:address, private deed : Deed) -> Deed{
        assert(deed.owner == self.caller);
        let encoded_domain_name : domainName = domainName{
            tld : deed.tld,
            name : deed.name,
            subname : deed.subname,
        };
        let update : Domain = Domain{
            current_owner : new_owner,
            registrar: 0u128,
            resolver: 0u128,
            name: encoded_domain_name,
            owner_hidden : false,
        };
        let new_deed : Deed = Deed{
            owner: new_owner,
            tld : encoded_domain_name.tld,
            name: encoded_domain_name.name,
            subname : encoded_domain_name.subname,
            registrar_name : 0u128,
            resolver_name : 0u128,
            data : BHP1024::hash_to_field(update),

        };
        return new_deed then finalize(encoded_domain_name, update);
    }
    finalize transfer_public_to_public(public encoded_domain_name : domainName, public update : Domain){
        domains.set(encoded_domain_name, update);
    }

    transition transfer_private_to_private(private new_owner:address, private deed : Deed) -> Deed{
        assert(deed.owner == self.caller);
        let encoded_domain_name : domainName = domainName{
            tld : deed.tld,
            name : deed.name,
            subname : deed.subname,
        };
        let hashed_new_owner : address = BHP1024::hash_to_address(new_owner);     
        let update : Domain = Domain{
            current_owner : hashed_new_owner,
            registrar: 0u128,
            resolver: 0u128,
            name: encoded_domain_name,
            owner_hidden : true,
        };
        let new_deed : Deed = Deed{
            owner: new_owner,
            tld : encoded_domain_name.tld,
            name: encoded_domain_name.name,
            subname : encoded_domain_name.subname,
            registrar_name : 0u128,
            resolver_name : 0u128,
            data : BHP1024::hash_to_field(update),

        };
        return new_deed then finalize(encoded_domain_name, return_null_domain(hashed_new_owner));
    }
    finalize transfer_private_to_private(public encoded_domain_name : domainName, public null_domain : Domain){
        domains.set(encoded_domain_name, null_domain);
    }

    transition transfer_public_to_private(private new_owner:address, private deed : Deed) -> Deed{
        assert(deed.owner == self.caller);
        let encoded_domain_name : domainName = domainName{
            tld : deed.tld,
            name : deed.name,
            subname : deed.subname,
        };
        let hashed_new_owner : address = BHP1024::hash_to_address(new_owner);     
        let update : Domain = Domain{
            current_owner : hashed_new_owner,
            registrar: 0u128,
            resolver: 0u128,
            name: encoded_domain_name,
            owner_hidden : true,
        };
        let new_deed : Deed = Deed{
            owner: new_owner,
            tld : encoded_domain_name.tld,
            name: encoded_domain_name.name,
            subname : encoded_domain_name.subname,
            registrar_name : 0u128,
            resolver_name : 0u128,
            data : BHP1024::hash_to_field(update),

        };
        return new_deed then finalize(encoded_domain_name, return_null_domain(hashed_new_owner));
    }
    finalize transfer_public_to_private(public encoded_domain_name : domainName, public null_domain : Domain){
        domains.set(encoded_domain_name, null_domain);
    }

    transition transfer_private_to_public(public new_owner:address, private deed : Deed) -> Deed{
        assert(deed.owner == self.caller);
        let encoded_domain_name : domainName = domainName{
            tld : deed.tld,
            name : deed.name,
            subname : deed.subname,
        };
        let update : Domain = Domain{
            current_owner : new_owner,
            registrar: 0u128,
            resolver: 0u128,
            name: encoded_domain_name,
            owner_hidden : false,
        };
        let new_deed : Deed = Deed{
            owner: new_owner,
            tld : encoded_domain_name.tld,
            name: encoded_domain_name.name,
            subname : encoded_domain_name.subname,
            registrar_name : 0u128,
            resolver_name : 0u128,
            data : BHP1024::hash_to_field(update),

        };
        return new_deed then finalize(encoded_domain_name, update);
    }
    finalize transfer_private_to_public(public encoded_domain_name : domainName, public update : Domain){        
        domains.set(encoded_domain_name, update);
    }
}
