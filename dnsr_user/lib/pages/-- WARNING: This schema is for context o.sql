-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE public.alerte (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  incident_id uuid,
  message text NOT NULL,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT alerte_pkey PRIMARY KEY (id),
  CONSTRAINT alerte_incident_id_fkey FOREIGN KEY (incident_id) REFERENCES public.incident(id)
);
CREATE TABLE public.categorie_incident (
  id integer NOT NULL DEFAULT nextval('categorie_incident_id_seq'::regclass),
  title text NOT NULL,
  CONSTRAINT categorie_incident_pkey PRIMARY KEY (id)
);
CREATE TABLE public.conseils_securite (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  titre text NOT NULL,
  contenu text NOT NULL,
  CONSTRAINT conseils_securite_pkey PRIMARY KEY (id)
);
CREATE TABLE public.historique_statut (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  incident_id uuid NOT NULL,
  ancien_statut USER-DEFINED NOT NULL DEFAULT 'EN_ATTENTE'::statut_incident,
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  details text,
  nouveau_statut USER-DEFINED DEFAULT 'EN_COURS'::statut_incident,
  CONSTRAINT historique_statut_pkey PRIMARY KEY (id),
  CONSTRAINT historique_statut_incident_id_fkey FOREIGN KEY (incident_id) REFERENCES public.incident(id)
);
CREATE TABLE public.incident (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  utilisateur_id uuid NOT NULL,
  description text,
  latitude double precision NOT NULL,
  longitude double precision NOT NULL,
  created_at timestamp without time zone NOT NULL DEFAULT now(),
  type_incident integer NOT NULL,
  type_vehicule integer,
  statut USER-DEFINED NOT NULL DEFAULT 'EN_ATTENTE'::statut_incident,
  CONSTRAINT incident_pkey PRIMARY KEY (id),
  CONSTRAINT incident_utilisateur_id_fkey FOREIGN KEY (utilisateur_id) REFERENCES public.utilisateurs(id),
  CONSTRAINT incident_type_incident_fkey FOREIGN KEY (type_incident) REFERENCES public.type_incident(id),
  CONSTRAINT incident_type_vehicule_fkey FOREIGN KEY (type_vehicule) REFERENCES public.type_vehicule(id)
);
CREATE TABLE public.incident_img (
  url character varying NOT NULL DEFAULT ''::character varying,
  incident_id uuid NOT NULL DEFAULT gen_random_uuid(),
  CONSTRAINT incident_img_pkey PRIMARY KEY (url),
  CONSTRAINT incident_img_incident_id_fkey FOREIGN KEY (incident_id) REFERENCES public.incident(id)
);
CREATE TABLE public.type_incident (
  id integer NOT NULL DEFAULT nextval('type_incident_id_seq'::regclass),
  title text NOT NULL,
  description text NOT NULL,
  categorie_id integer,
  CONSTRAINT type_incident_pkey PRIMARY KEY (id),
  CONSTRAINT type_incident_categorie_id_fkey FOREIGN KEY (categorie_id) REFERENCES public.categorie_incident(id)
);
CREATE TABLE public.type_vehicule (
  id integer NOT NULL DEFAULT nextval('type_vehicule_id_seq'::regclass),
  title text NOT NULL,
  CONSTRAINT type_vehicule_pkey PRIMARY KEY (id)
);
CREATE TABLE public.utilisateurs (
  id uuid NOT NULL DEFAULT auth.uid(),
  nom text NOT NULL DEFAULT ''::text,
  prenom text NOT NULL DEFAULT ''::text,
  email character varying NOT NULL DEFAULT ''::character varying UNIQUE,
  numero_telephone text DEFAULT ''::text,
  role USER-DEFINED NOT NULL DEFAULT 'CITOYEN'::role_utilisateur,
  status USER-DEFINED NOT NULL DEFAULT 'DEACTIVATED'::statut_utilisateur,
  deactivated_at timestamp with time zone,
  updated_at timestamp without time zone,
  latitude double precision,
  longitude double precision,
  created_at timestamp with time zone NOT NULL DEFAULT (now() AT TIME ZONE 'utc'::text) UNIQUE,
  fcm_token text,
  CONSTRAINT utilisateurs_pkey PRIMARY KEY (id),
  CONSTRAINT utilisateurs_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id)
);