const route = require("express").Router();
const conexao = require("../database/config.js")



route.post("/insert",(req,res)=>{
    conexao.query(`INSERT INTO usuarios SET ?`,req.body,(error,result)=>{
        if(error){
        return res.status(500).send({flag:`Error`,msg:`Erro ao cadastrar a instituição -> ${error}`});
    }
    return res.status(201).send({flag:`OK`,payload:result})
    })
});


route.post("/login",(req,res)=>{
    conexao.query(`SELECT * FROM usuarios WHERE email=? and senha_hash=?`,req.body,(error,result)=>{
        if(error){
        return res.status(500).send({flag:`Error`,msg:`Erro ao cadastrar a instituição -> ${error}`});
    }
    return res.status(201).send({flag:`OK`,payload:result})
    })
});





route.get("/list",(req,res)  =>{
    conexao.query(`SELECT * FROM usuarios`,(error,result)=>{
        if(error){
            return res.status(500).send({flag:`Error`,msg:`Erro ao cadastrar a instituição -> ${error}`});
        }
        return res.status(200).send({flag:`OK`,payload:result});
    });
})

route.get("/list_id/:id",(req,res)=>{
    conexao.query(`SELECT * FROM usuarios WHERE id=?`,req.params.id,(error,result)=>{
if(error){
            return res.status(500).send({flag:`Error`,msg:`Erro ao cadastrar a instituição -> ${error}`});
        }
        return res.status(200).send({flag:`OK`,payload:result});
    });
})

route.get("/list_email/:email",(req,res)=>{
    conexao.query(`SELECT * FROM usuarios WHERE email=?`,req.params.email,(error,result)=>{
if(error){
            return res.status(500).send({flag:`Error`,msg:`Erro ao cadastrar a instituição -> ${error}`});
        }
        return res.status(200).send({flag:`OK`,payload:result});
    });
})

route.get("/list_perfil/:perfil",(req,res)=>{
    conexao.query(`SELECT * FROM usuarios WHERE perfil=?`,req.params.perfil,(error,result)=>{
if(error){
            return res.status(500).send({flag:`Error`,msg:`Erro ao cadastrar a instituição -> ${error}`});
        }
        return res.status(200).send({flag:`OK`,payload:result});
    });
})

route.get("/list_nome/:nome",(req,res)=>{
    const q = `%${req.params.nome}%`
    conexao.query(`SELECT * FROM usuarios WHERE nome LIKE ?`,q,(error,result)=>{
if(error){
            return res.status(500).send({flag:`Error`,msg:`Erro ao cadastrar a instituição -> ${error}`});
        }
        return res.status(200).send({flag:`OK`,payload:result});
    });
})
route.put("/update/:id",(req,res)=>{
    conexao.query(`UPDATE usuarios SET ? WHERE id = ?`,[req.body, req.params.id],(error,result)=>{
        if(error){
            return res.status(500).send({flag:`Error`,msg:`Erro ao tentar atualizar os dados da instituição -> ${error}`});
        }
        return res.status(200).send({flag:`OK`,playload:result})
    })
})

route.get("/gestao_usuarios",(req,res)=>{
    const sql = `SELECT 
    -- Tratamento para o Super Administrador que não possui uma instituição específica
    COALESCE(inst.nome, 'Sistema Global (Múltiplas Instituições)') AS Instituicao,
    inst.cnpj AS CNPJ_Instituicao,
    inst.tipo AS Tipo_Ensino,
    
    -- Dados do Usuário
    u.nome AS Nome_Usuario,
    u.email AS Email_Usuario,
    u.perfil AS Perfil_Acesso,
    
    -- Tradução do status booleano para texto
    CASE 
        WHEN u.ativo = 1 THEN 'Ativo' 
        ELSE 'Inativo' 
    END AS Status_Usuario

FROM 
    usuarios u
LEFT JOIN 
    instituicoes inst ON u.instituicao_id = inst.id
ORDER BY 
    -- Ordena primeiro pelas instituições, depois pelo nível de acesso e ordem alfabética
    inst.nome ASC, 
    u.perfil ASC, 
    u.nome ASC;`
 conexao.query(sql,(error,result)=>{
    if(error){
            return res.status(500).send({flag:`Error`,msg:`Erro ao cadastrar a instituição -> ${error}`});
        }
        return res.status(200).send({flag:`OK`,payload:result});
    });
    });


module.exports = route;