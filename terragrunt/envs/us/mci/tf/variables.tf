variable project_id {
    type = string
    default = ""
}

variable cluster_id {
    type = string
    description = "Cluster id to become member."
    default = ""
}

variable cluster_name {
    description = "Cluster name to become member."
    type = string
    default = ""
}

variable region {
    type = string
    default = ""
}
