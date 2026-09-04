const route = require("express").Router();
const conexao = require("../database/config.js")



route.post("/insert",(req,res)=>{
    conexao.query(`INSERT INTO locais SET ?`,req.body,(error,result)=>{
        if(error){
        return res.status(500).send({flag:`Error`,msg:`Erro ao cadastrar a locais -> ${error}`});
    }
    return res.status(201).send({flag:`OK`,payload:result})
    })
});

route.get("/list",(req,res)  =>{
    conexao.query(`SELECT * FROM locais`,(error,result)=>{
        if(error){
            return res.status(500).send({flag:`Error`,msg:`Erro ao cadastrar a locais -> ${error}`});
        }
        return res.status(200).send({flag:`OK`,payload:result});
    });
})

route.get("/list_id/:id",(req,res)=>{
    conexao.query(`SELECT * FROM locais WHERE id=?`,req.params.id,(error,result)=>{
if(error){
            return res.status(500).send({flag:`Error`,msg:`Erro ao cadastrar a locais -> ${error}`});
        }
        return res.status(200).send({flag:`OK`,payload:result});
    });
})

route.get("/list_nome/:nome",(req,res)=>{
    const q = `%${req.params.nome}%`
    conexao.query(`SELECT * FROM locais WHERE nome LIKE ?`,q,(error,result)=>{
if(error){
            return res.status(500).send({flag:`Error`,msg:`Erro ao cadastrar a locais -> ${error}`});
        }
        return res.status(200).send({flag:`OK`,payload:result});
    });
})

route.get("/list_descricao/:descricao",(req,res)=>{
    const q = `%${req.params.descricao}%`
    conexao.query(`SELECT * FROM locais WHERE descricao LIKE ?`,q,(error,result)=>{
if(error){
            return res.status(500).send({flag:`Error`,msg:`Erro ao cadastrar a locais -> ${error}`});
        }
        return res.status(200).send({flag:`OK`,payload:result});
    });
})


route.put("/update/:id",(req,res)=>{
    conexao.query(`UPDATE locais SET ? WHERE id = ?`,[req.body, req.params.id],(error,result)=>{
        if(error){
            return res.status(500).send({flag:`Error`,msg:`Erro ao tentar atualizar os dados da locais -> ${error}`});
        }
        return res.status(200).send({flag:`OK`,playload:result})
    })
})

module.exports = route;